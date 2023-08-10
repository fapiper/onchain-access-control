package main

import (
    "net/http"

    "github.com/gin-gonic/gin"
)

func main() {
    engine:= gin.Default()
    engine.GET("/", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{
            "message": "hello world from issuer",
        })
    })
    engine.Run(":3002")

    // Step 1: Create DID if not already created
    // Step 2: Register VC Schema if not already registered
    // Step 3: Listen to requests
}
