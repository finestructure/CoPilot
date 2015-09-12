package main

import (
    "log"
    "net/http"
    "time"
    "fmt"

    "github.com/gorilla/websocket"
    "github.com/gorilla/mux"
    "code.google.com/p/go-uuid/uuid"
)

const (
    writeWait = 10 * time.Second
    pongWait = 60 * time.Second
    pingPeriod = (pongWait * 9) / 10
    maxMessageSize = 1024 * 1024
)

type client struct {
    id string
    ws *websocket.Conn
    send chan []byte
    doc *doc
}

var upgrader = websocket.Upgrader{
    ReadBufferSize:  maxMessageSize,
    WriteBufferSize: maxMessageSize,
}

func Connect(w http.ResponseWriter, r *http.Request) {
    id := mux.Vars(r)["id"]
    d := GetDoc(id)
    
    if d == nil {
        w.WriteHeader(404)
        return
    }
    
    ws, err := upgrader.Upgrade(w, r, nil)
    if err != nil {
        log.Println(err)
        return
    }
    
    c := &client{
        id: uuid.New(),
        send: make(chan []byte, maxMessageSize),
        ws: ws,
        doc: d,
    }
    
    d.register <- c
    
    go c.writePump()
    c.readPump()
}

func (c *client) readPump() {
    defer func() {
        c.doc.unregister <- c
        c.ws.Close()
    }()
    
    c.ws.SetReadLimit(maxMessageSize)
    c.ws.SetReadDeadline(time.Now().Add(pongWait))
    c.ws.SetPongHandler(func(string) error {
        c.ws.SetReadDeadline(time.Now().Add(pongWait));
        return nil
    })
    
    for {
        _, content, err := c.ws.ReadMessage()
        if err != nil {
            break
        }
        
        fmt.Println("readPump:", string(content))
        message := message{content, c}
        c.doc.broadcast <- message
    }
}

func (c *client) writePump() {
    ticker := time.NewTicker(pingPeriod)
    
    defer func() {
        ticker.Stop()
        c.ws.Close()
    }()
    
    for {
        select {
        case message, ok := <-c.send:
            // fmt.Println("writePump:", ok, string(message))
            if !ok {
                c.write(websocket.CloseMessage, []byte{})
                return
            }
            if err := c.write(websocket.BinaryMessage, message); err != nil {
                return
            }
        case <-ticker.C:
            if err := c.write(websocket.PingMessage, []byte{}); err != nil {
                return
            }
        }
    }
}

func (c *client) write(mt int, message []byte) error {
    c.ws.SetWriteDeadline(time.Now().Add(writeWait))
    return c.ws.WriteMessage(mt, message)
}
