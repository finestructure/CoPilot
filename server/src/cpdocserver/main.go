package main

import (
  "io"
  "net/http"
  "doc"

  "github.com/gorilla/mux"
  "golang.org/x/net/websocket"
)


func main() {
  router := mux.NewRouter()

  router.NewRoute().Path("/doc/{id}/publish").HandlerFunc(publish)
  router.NewRoute().Path("/doc/{id}/subscribe").HandlerFunc(subscribe)

  http.Handle("/", router)
  http.ListenAndServe(":12345", nil)
}


func subscribe(writer http.ResponseWriter, req *http.Request) {
  id := mux.Vars(req)["id"]
  doc := doc.Find(id)
  if doc == nil {
    writer.WriteHeader(404)
  } else {
    websocket.Handler(
      func(ws *websocket.Conn) {
        ws.PayloadType = 2
        doc.Subscribe(ws)
      }).ServeHTTP(writer, req)
  }
}


func publish(writer http.ResponseWriter, req *http.Request) {
  id := mux.Vars(req)["id"]
  doc := doc.New(id)
  websocket.Handler(
    func(ws *websocket.Conn) {
      io.Copy(doc, ws)
    }).ServeHTTP(writer, req)
}
