//go:build mage
// +build mage

package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
)

// Mage settings
var (
	Default = TestAndBuild
)

const (
	REPO_NAME = "x-files"
	// Go build environment settings
	GOOS        = "linux"
	GOARCH      = "amd64"
	CGO_ENABLED = "0"
)

// See init()
var (
	// The directory of the repository root (not necessarily this magefile)
	repoRootDir = ""
	// Build paths
	appDir   = ""
	buildDir = ""
)

func init() {
	r, err := findAbsRepoRoot()
	if err != nil {
		panic(err)
	}

	// Set globals
	repoRootDir = r
	appDir = filepath.Join(repoRootDir, "app")
	buildDir = filepath.Join(repoRootDir, "build")

	// Set starting point
	err = os.Chdir(repoRootDir)
	if err != nil {
		panic(err)
	}
}

/*
Mage targets
*/

// TestAndBuild runs the Test and Build targets
func TestAndBuild() error {
	mg.Deps(Test, Build)
	return nil
}

// Test runs unit tests
func Test() error {
	return runInDir(appDir, "go", "test", ".", "-v")
}

// Build builds the application binary and copies assets
func Build() error {
	var err error

	fmt.Printf("Ensuring %s exists\n", buildDir)

	err = os.MkdirAll(buildDir, 0755)
	if err != nil {
		return err
	}

	goos, found := os.LookupEnv("GOOS")
	if !found {
		goos = GOOS
	}
	goarch, found := os.LookupEnv("GOARCH")
	if !found {
		goarch = GOARCH
	}
	cgo, found := os.LookupEnv("CGO_ENABLED")
	if !found {
		cgo = CGO_ENABLED
	}

	fmt.Printf("Building application (%s/main.go) for: %s/%s (Cgo: %s)\n", appDir, goos, goarch, cgo)

	err = runInDir(appDir, "go", "build", "-o", fmt.Sprintf("%s/app", buildDir), "main.go")
	if err != nil {
		return err
	}

	fmt.Printf("Copying assets from %s to %s\n", appDir, buildDir)

	err = runInDir(appDir, "cp", "index.html", fmt.Sprintf("%s/index.html", buildDir))
	if err != nil {
		return err
	}

	err = runInDir(appDir, "cp", "styles.css", fmt.Sprintf("%s/styles.css", buildDir))
	if err != nil {
		return err
	}

	fmt.Println("Done. Build output:")

	out, err := sh.Output("ls", "-laR", buildDir)
	if err != nil {
		return err
	}
	if out != "" {
		fmt.Println(out)
	}

	fmt.Println("******************************************************")
	fmt.Printf("Run in debug mode: %s/app\n", buildDir)
	fmt.Printf("Run in production mode: GIN_MODE=release %s/app\n", buildDir)
	fmt.Println("******************************************************")

	return nil
}

// Clean deletes build artifacts
func Clean() error {
	fmt.Printf("Deleting %s\n", buildDir)

	return os.RemoveAll(buildDir)
}

/*
Helpers
*/

// findAbsRepoRoot finds the repository path that is used as the root path for all operations
func findAbsRepoRoot() (string, error) {
	cwd, err := filepath.Abs(".")
	if err != nil {
		return "", err
	}

	if !strings.Contains(cwd, REPO_NAME) {
		return "", fmt.Errorf("Did not find repository root from path %s.", cwd, REPO_NAME)
	}

	pathRegex := regexp.MustCompile(fmt.Sprintf(`.*/%s`, REPO_NAME))
	absRepoRoot := pathRegex.FindString(cwd)
	if absRepoRoot == "" {
		return "", fmt.Errorf("Could not parse repository root from path %s.")
	}

	return absRepoRoot, nil
}

// runInDir runs a command in a directory, that always outputs, regardless of mage verbosity.
// Can be used for targets running in parallel and skip using the non-parallel safe os.Chdir().
// Mage does not support concurrently running os.Chdir().
func runInDir(dir string, cmd string, args ...string) error {
	command := exec.Command(cmd, args...)
	command.Dir = dir

	out, err := command.Output()
	if err != nil {
		return err
	}
	if len(out) != 0 {
		fmt.Println(string(out))
	}

	return nil

}
