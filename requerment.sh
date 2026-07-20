#!/bin/bash

set -e

echo 'Updating system...'
sudo dnf update -y || sudo yum update -y

echo 'Installing basic tools...'
sudo dnf install -y git curl wget unzip zip jq tree vim nano tar gzip which || \
sudo yum install -y git curl wget unzip zip jq tree vim nano tar gzip which

echo 'Installing Docker...'
sudo dnf install -y docker || sudo yum install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user

echo 'Installing AWS CLI v2...'
curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o awscliv2.zip
unzip -o awscliv2.zip
sudo ./aws/install --update
rm -rf aws awscliv2.zip

echo 'Installing kubectl...'
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo 'Installing eksctl...'
curl --silent --location 'https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz' | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

echo 'Installing Terraform...'
sudo dnf install -y yum-utils || sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo || true
sudo dnf install -y terraform || sudo yum install -y terraform


echo 'Installed versions:'
git --version
docker --version
aws --version
kubectl version --client
eksctl version
terraform version


echo 'Done! Run: newgrp docker (or log out and back in to use Docker without sudo)'