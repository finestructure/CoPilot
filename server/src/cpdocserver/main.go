// Based on GollabEdit https://github.com/marmelab/gollabedit

package main

import (
    "log"
    "net/http"

    "github.com/gorilla/mux"
)


func main() {
    router := mux.NewRouter()

    router.NewRoute().Path("/doc/{id}").HandlerFunc(Connect)

    http.Handle("/", router)
    log.Fatal(http.ListenAndServe(":12345", nil))
}
