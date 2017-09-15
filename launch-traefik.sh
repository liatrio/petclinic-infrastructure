#!/bin/bash

docker run -d --network bridge \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /home/ec2-user/traefik.toml:/etc/traefik/traefik.toml:ro \
  -v /home/ec2-user/acme:/etc/traefik/acme -p 80:80 -p 443:443 \
  -p 8080:8080 --name traefik traefik 
