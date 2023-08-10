package main

import (
    "net/http"

    "github.com/gin-gonic/gin"
)

func main() {
    engine:= gin.Default()
    engine.GET("/", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{
            "message": "hello world from data owner",
        })
    })
    engine.Run(":3003")

    // Step 1: Create DID if not already created
    // Step 2: Register data with DID (if not already registered) and auth (DID -> role -> verifier)
    // Step 3: Listen to data requests
}
