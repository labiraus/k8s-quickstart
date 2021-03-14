package main

import (
	"context"
	"fmt"
	"k8s-quickstart/pkg/api"
	"k8s-quickstart/pkg/types/user"
	"log"
	"net/http"
	"os"
	"os/signal"
)

func main() {
	fmt.Println("user starting")
	ctx, ctxDone := context.WithCancel(context.Background())
	done := api.StartBasicApi(ctx, userHandler)
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	s := <-c
	ctxDone()
	fmt.Println("hello got signal: " + s.String() + " now closing")
	<-done
}

func userHandler(w http.ResponseWriter, r *http.Request) {
	defer func() {
		r := recover()
		if r != nil {
			log.Println(r)
		}
	}()

	var request = user.UserRequest{}
	err := api.UnmarshalRequest(&request, r)
	if err != nil {
		log.Println(err)
		return
	}
	fmt.Printf("user handler got %#v\n", request)

	response := user.UserResponse{Greeting: "from " + request.UserName}
	fmt.Printf("user handler sending %#v\n", response)
	api.MarshalResponse(response, w)
}
