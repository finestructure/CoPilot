#!/bin/sh
docker stop some-rabbit
docker rm some-rabbit
docker run -d --hostname my-rabbit --name some-rabbit -p 5672:5672 -p 8080:15672 rabbitmq:3-management
echo open "http://localhost:8080"
