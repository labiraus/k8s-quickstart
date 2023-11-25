package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"os/signal"
)

const (
	serviceName = "webserverapi"
)

var (
	Info  *log.Logger
	Error *log.Logger
	ready chan struct{}
)

func main() {
	ready = make(chan struct{})
	Info = log.New(os.Stdout, "INFO ["+serviceName+"]: ", log.Ldate|log.Ltime|log.Lshortfile)
	Error = log.New(os.Stderr, "ERROR ["+serviceName+"]: ", log.Ldate|log.Ltime|log.Lshortfile)
	Info.Println("starting")

	ctx, ctxDone := context.WithCancel(context.Background())
	done := startApi(ctx)
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	s := <-c
	ctxDone()
	Info.Println("got signal: [" + s.String() + "] now closing")
	<-done
}

func startApi(ctx context.Context) <-chan struct{} {
	done := make(chan struct{})
	srv := &http.Server{Addr: "0.0.0.0:8080"}
	http.HandleFunc("/hello", helloHandler)
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
	close(ready)
	return done
}

func helloHandler(w http.ResponseWriter, r *http.Request) {
	var err error
	defer func() {
		r := recover()
		if err != nil {
			Error.Println(err)
		}
		if r != nil {
			Error.Println(r)
		}
	}()

	response := HelloResponse{Data: "Hello thar!"}

	data, err := json.Marshal(response)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	_, err = w.Write(data)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
}

func readinessHandler(w http.ResponseWriter, r *http.Request) {
	<-ready
	w.WriteHeader(http.StatusOK)
}
func livelinessHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
}
