//go:build mage
// +build mage

package main

import (
	"fmt"
	"os"
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
	repoRoot = ""
	appDir   = ""
	buildDir = ""
)

func init() {
	r, err := findAbsRepoRoot()
	if err != nil {
		panic(err)
	}

	// Set globals
	repoRoot = r
	appDir = filepath.Join(repoRoot, "app")
	buildDir = filepath.Join(repoRoot, "build")

	// Set starting point
	err = os.Chdir(repoRoot)
	if err != nil {
		panic(err)
	}
}

/*
Mage targets
*/

// TestAndBuild runs the Test and Build targets
func TestAndBuild() error {
	mg.SerialDeps(Test, Build)
	return nil
}

// Test runs unit tests
func Test() error {
	err := os.Chdir(appDir)
	if err != nil {
		return err
	}
	defer os.Chdir(repoRoot)

	out, err := sh.Output("go", "test", ".", "-v")
	if err != nil {
		return err
	}
	fmt.Println(out)

	return nil
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

	err = os.Chdir(appDir)
	if err != nil {
		return err
	}
	defer os.Chdir(repoRoot)

	err = run("go", "build", "-o", fmt.Sprintf("%s/app", buildDir), "main.go")
	if err != nil {
		return err
	}

	fmt.Printf("Copying assets from %s to %s\n", appDir, buildDir)

	err = run("cp", "index.html", fmt.Sprintf("%s/index.html", buildDir))
	if err != nil {
		return err
	}

	err = run("cp", "styles.css", fmt.Sprintf("%s/styles.css", buildDir))
	if err != nil {
		return err
	}

	fmt.Println("Done. Build output:")
	run("ls", "-laR", buildDir)
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

// run runs a command that always outputs, regardless of mage verbosity
func run(cmd string, args ...string) error {
	out, err := sh.Output(cmd, args...)
	if err != nil {
		return err
	}
	if out != "" {
		fmt.Println(out)
	}

	return nil
}
