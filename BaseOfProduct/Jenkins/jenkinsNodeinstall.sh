#!/bin/bash
mkdir /home/ec2-user/jenkins
sudo chown ec2-user:ec2-user /home/ec2-user/jenkins && \
#sudo yum update -y
sudo yum install java-1.8.0-openjdk -y && \
sudo amazon-linux-extras install docker -y && \
sudo systemctl start docker && \
sudo usermod -a -G docker ec2-user && \
sudo systemctl enable docker && \
sudo yum -y install git && \
sudo yum -y install python-pip && \
pip install boto && \
sudo amazon-linux-extras install ansible2 -y && \
sudo yum install maven -y
