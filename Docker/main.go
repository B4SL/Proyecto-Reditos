package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("Serving request: %s", r.URL.Path)
		host, _ := os.Hostname()
		fmt.Fprintf(w, "Hello, World!\n")
		fmt.Fprintf(w, "Hostname: %s\n", host)
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Starting server on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
