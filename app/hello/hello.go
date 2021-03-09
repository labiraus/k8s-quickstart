package main

import (
	"context"
	"fmt"
	"k8s-quickstart/pkg/api"
	"os"
	"os/signal"
)

// This example demonstrates a trivial echo server.
func main() {
	fmt.Println("hello starting")
	ctx, ctxDone := context.WithCancel(context.Background())
	done := api.StartHello(ctx)
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	s := <-c
	ctxDone()
	fmt.Println("hello got signal: " + s.String() + " now closing")
	<-done
}
