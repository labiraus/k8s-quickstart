package api

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
)

var (
	ready = make(chan struct{})
	Info  *log.Logger
	Error *log.Logger
)

func Init(serviceName string) <-chan struct{} {
	Info = log.New(os.Stdout, "INFO ["+serviceName+"]: ", log.Ldate|log.Ltime|log.Lshortfile)
	Error = log.New(os.Stderr, "ERROR ["+serviceName+"]: ", log.Ldate|log.Ltime|log.Lshortfile)
	Info.Println("starting")
	ctx, ctxDone := context.WithCancel(context.Background())

	done := make(chan struct{})
	srv := &http.Server{Addr: "0.0.0.0:8080"}
	http.HandleFunc("/readiness", readinessHandler)
	http.HandleFunc("/liveness", livelinessHandler)

	go func() {
		if err := srv.ListenAndServe(); err != http.ErrServerClosed {
			panic("ListenAndServe: " + err.Error())
		}
	}()

	go func() {
		defer close(done)

		<-ctx.Done()
		if err := srv.Shutdown(ctx); err != nil {
			Error.Println("Shutdown: " + err.Error())
		}
	}()

	go func() {
		c := make(chan os.Signal, 1)
		signal.Notify(c, os.Interrupt)
		s := <-c
		Info.Println("got signal: [" + s.String() + "] now closing")
		ctxDone()
	}()

	close(ready)
	return done
}

func readinessHandler(w http.ResponseWriter, r *http.Request) {
	<-ready
	w.WriteHeader(http.StatusOK)
}

func livelinessHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
}
