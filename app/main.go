package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	r.GET("/ping", func(c *gin.Context) {
		c.String(http.StatusOK, "pong")
	})

	r.LoadHTMLFiles("index.html")
	r.StaticFile("styles.css", "styles.css")
	r.GET("/", func(c *gin.Context) {
		c.HTML(http.StatusOK, "index.html", struct{ Text string }{
			Text: "Hello, World!",
		})
	})

	r.Run(":3000")
}
