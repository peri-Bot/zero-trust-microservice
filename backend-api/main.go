package main

import (
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "healthy", "service": "backend"})
	})

	r.GET("/data", func(c *gin.Context) {
		secretPath := "/vault/secrets/database-config.txt"
		data, err := os.ReadFile(secretPath)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error":  "failed to read vault secret",
				"path":   secretPath,
				"detail": err.Error(),
			})
			return
		}
		c.Data(http.StatusOK, "application/json", data)
	})

	r.Run(":8080")
}
