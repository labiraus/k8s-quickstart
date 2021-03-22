package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/signal"
)

func main() {
	fmt.Println("user starting")
	ctx, ctxDone := context.WithCancel(context.Background())
	done := startApi(ctx)
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	s := <-c
	ctxDone()
	fmt.Println("user got signal: " + s.String() + " now closing")
	<-done
}

func startApi(ctx context.Context) <-chan struct{} {
	done := make(chan struct{})
	srv := &http.Server{Addr: "0.0.0.0:8080"}
	http.HandleFunc("/", userHandler)
	go func() {
		if err := srv.ListenAndServe(); err != http.ErrServerClosed {
			panic("ListenAndServe: " + err.Error())
		}
	}()
	go func() {
		defer close(done)

		<-ctx.Done()
		if err := srv.Shutdown(ctx); err != nil {
			log.Println("Shutdown: " + err.Error())
		}
	}()

	return done
}

func userHandler(w http.ResponseWriter, r *http.Request) {
	var err error
	defer func() {
		r := recover()
		if r != nil {
			log.Println(err)
			w.WriteHeader(http.StatusInternalServerError)
		}
	}()

	var request = UserRequest{}
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Println(err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	err = json.Unmarshal(body, &request)
	if err != nil {
		log.Println(err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	response := UserResponse{Greeting: "from " + request.UserName}

	data, err := json.Marshal(response)
	if err != nil {
		log.Println(err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	_, err = w.Write(data)
	if err != nil {
		log.Println(err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
}
