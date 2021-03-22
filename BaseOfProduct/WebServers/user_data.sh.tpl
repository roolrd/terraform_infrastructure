#!/bin/bash
sudo amazon-linux-extras install docker -y && \
sudo systemctl start docker && \
sudo usermod -a -G docker ec2-user && \
sudo systemctl enable docker && \
#sudo yum -y install python-pip && \
#pip install boto && \

sleep 5

docker run --name bop --rm \
-e dbConnectionUrl=jdbc:mysql://${dburl}:3306/base_products \
-e dbPassword=${pass} \
-e dbUserName=root \
-p 80:8080 -d roolrd/base_of_product:latest
