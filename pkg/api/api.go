package api

import (
	"context"
	"fmt"
	"net/http"
)

//StartHello stars the hello web server
func StartHello(ctx context.Context) <-chan struct{} {
	done := make(chan struct{})
	srv := &http.Server{Addr: "0.0.0.0:8080"}
	http.HandleFunc("/", helloHandler)
	go func() {
		fmt.Println("starting hello")

		if err := srv.ListenAndServe(); err != http.ErrServerClosed {
			panic("ListenAndServe: " + err.Error())
		}
	}()
	go func() {
		defer close(done)

		<-ctx.Done()
		if err := srv.Shutdown(ctx); err != nil {
			fmt.Println("Shutdown: " + err.Error())
		}
	}()
	// _ = http.ListenAndServe("0.0.0.0:8080", nil)
	return done
}
