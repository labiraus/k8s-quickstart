package api

import (
	"fmt"
	"net/http"
)

// Handler handles connections
func helloHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Println("HelloHandler connection")
	fmt.Fprintf(w, "Hi there, I hate %s!", r.URL.Path[1:])
}
