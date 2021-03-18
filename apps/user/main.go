package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
)

func main() {
	fmt.Println("user starting")
	ctx, ctxDone := context.WithCancel(context.Background())
	done := StartBasicApi(ctx, userHandler)
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

	var request = UserRequest{}
	err := UnmarshalRequest(&request, r)
	if err != nil {
		log.Println(err)
		return
	}
	fmt.Printf("user handler got %#v\n", request)

	response := UserResponse{Greeting: "from " + request.UserName}
	fmt.Printf("user handler sending %#v\n", response)
	MarshalResponse(response, w)
}
