package main

import (
	"net/http"
  "fmt"
  
  "github.com/gorilla/mux"
)

type doc struct {
	clients map[*client]bool
	broadcast chan []byte
	register chan *client
	unregister chan *client
}


var docs = make(map[string]*doc)


func publish(w http.ResponseWriter, r *http.Request) {
  id := mux.Vars(r)["id"]

  _, exists := docs[id]
  if exists {
    // deny replulishing of existing id
    w.WriteHeader(404)
    return
  }

  fmt.Println("New:", id)
  d := &doc{
  	broadcast:   make(chan []byte, maxMessageSize),
  	register:    make(chan *client),
  	unregister:  make(chan *client),
  	clients:     make(map[*client]bool),
  }

  go d.run()

  docs[id] = d
}


func (d *doc) run() {
	for {
		select {
		case c := <- d.register:
			d.clients[c] = true
			break

		case c := <- d.unregister:
			_, ok := d.clients[c]
			if ok {
				delete(d.clients, c)
				close(c.send)
			}
			break

		case m := <- d.broadcast:
			d.broadcastMessage(m)
			break
		}
	}
}


func (d *doc) broadcastMessage(m []byte) {
	for c := range d.clients {
		select {
		case c.send <- m:
			break

		// We can't reach the client
		default:
			close(c.send)
			delete(d.clients, c)
		}
	}
}
