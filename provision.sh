#!/bin/bash

sudo yum update -y

sudo yum install -y docker 

sudo service docker start

sudo usermod -a -G docker ec2-user

mkdir /home/ec2-user/acme
touch /home/ec2-user/acme/acme.json
