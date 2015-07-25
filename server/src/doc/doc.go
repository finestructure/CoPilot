package doc

import (
  "container/list"
  "io"
  "fmt"
)


type subscriber chan []byte


type doc struct {
  subscribers *list.List
  subscribe   chan subscriber
  unsubscribe chan subscriber
  broadcast   chan []byte
}


var docs = make(map[string]*doc)


func New(id string) *doc {
  fmt.Println("New:", id)
  d := &doc{list.New(), make(chan subscriber), make(chan subscriber), make(chan []byte, 100)}

  go d.run()

  docs[id] = d

  return d
}


func Find(id string) *doc {
  return docs[id]
}


func (d *doc) Subscribe(w io.Writer) {
  ch := make(chan []byte)
  d.subscribe <- ch

  for bytes := range ch {
    _, err := w.Write(bytes)
    if err != nil {
      break
    }
  }

  d.unsubscribe <- ch
}


func (d *doc) Write(bytes []byte) (int, error) {
  fmt.Println("Write:", len(bytes))
  d.broadcast <- bytes
  return len(bytes), nil
}


func (d *doc) run() {
  for {
    select {
    case subscriber := <- d.subscribe:
      d.addSubscriber(subscriber)
    case subscriber := <- d.unsubscribe:
      d.removeSubscriber(subscriber)
    case data := <-d.broadcast:
      forward(data, d.subscribers)
    }
  }
}


func (d *doc) addSubscriber(subscriber interface{}) {
  d.subscribers.PushFront(subscriber)
}


func (d *doc) removeSubscriber(subscriber interface{}) {
  for s := d.subscribers.Front(); s != nil; s = s.Next() {
    if s.Value == subscriber {
      d.subscribers.Remove(s)
      break
    }
  }
}


func forward(data []byte, l *list.List) {
  fmt.Println("forward:", len(data))
  for s := l.Front(); s != nil; s = s.Next() {
    s.Value.(subscriber) <- data
  }
}
