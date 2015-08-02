package main


import (
  "fmt"
)


type message struct {
  content []byte
  sender  *client
}


type doc struct {
  id string
	clients map[*client]bool
	broadcast chan message
	register chan *client
	unregister chan *client
  master *client
}


var docs = make(map[string]*doc)


func GetDoc(id string) *doc { 
  if _, exists := docs[id]; !exists {
    fmt.Println("New:", id)
    d := &doc{
      id:          id,
    	broadcast:   make(chan message, 1024),
    	register:    make(chan *client),
    	unregister:  make(chan *client),
    	clients:     make(map[*client]bool),
    }
    docs[id] = d
  }
  d := docs[id]
  
  go d.run()
  
  return d
}


func (d *doc) run() {
	for {
		select {
		case c := <- d.register:
      if d.master == nil {
        d.master = c
      }
			d.clients[c] = true
			break

		case c := <- d.unregister:
			_, ok := d.clients[c]
			if ok {
				delete(d.clients, c)
			}
      
      // close the document if there are no more clients
      if len(d.clients) == 0 {
        delete(docs, d.id)
      }
      
      // if the master unregistered, we close everything down
      if c == d.master {
        for i := range d.clients {
          close(i.send)
        }
        delete(docs, d.id)
      }
			break

		case m := <- d.broadcast:
			d.broadcastMessage(m)
			break
		}
	}
}


func (d *doc) broadcastMessage(m message) {
	for c := range d.clients {
    // don't echo to sender
    if c == m.sender {
      continue
    }
    
    select {
    case c.send <- m.content:
      break

    // can't reach the client
    default:
      close(c.send)
      delete(d.clients, c)
    }
  }
}
