package main

import (
  "log"
  "net/http"

  "github.com/gorilla/mux"
)


func main() {
  router := mux.NewRouter()

  router.NewRoute().Path("/doc/{id}/publish").HandlerFunc(publish)
  router.NewRoute().Path("/doc/{id}/subscribe").HandlerFunc(subscribe)

  http.Handle("/", router)
  log.Fatal(http.ListenAndServe(":12345", nil))
}
