#!/bin/bash

ip=$(ip route get 1.2.3.4 | grep 1.2.3.4 | awk '{print $NF; exit}')

docker rm -f consul || true
docker run -d --name consul --net=host -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' consul agent -server -bind="$ip" -client="$ip" -bootstrap-expect=1
