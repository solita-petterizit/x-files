package main

import (
	"net/http"
	"os"
	"path/filepath"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	r.GET("/ping", func(c *gin.Context) {
		c.String(http.StatusOK, "pong")
	})

	// We expect files to be in the same directory as the application
	appPath, err := os.Executable()
	if err != nil {
		panic(err)
	}
	workDir := filepath.Dir(appPath)

	r.LoadHTMLFiles(filepath.Join(workDir, "index.html"))
	r.StaticFile("styles.css", filepath.Join(workDir, "styles.css"))
	r.GET("/", func(c *gin.Context) {
		c.HTML(http.StatusOK, "index.html", struct{ Text string }{
			Text: "Hello, World!",
		})
	})

	r.Run(":3000")
}
