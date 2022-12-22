ARG VARIANT="3.16"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-alpine-${VARIANT}

RUN apk upgrade --update-cache --available && \
    apk add nodejs npm && \
    apk add py3-pip gcc musl-dev python3-dev libffi-dev openssl openssl-dev cargo make && \
    rm -rf /var/cache/apk/*

RUN pip install --upgrade pip
RUN pip install azure-cli

RUN release=`curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest |  grep tag_name | cut -d: -f2 | tr -d \"\,\v | awk '{$1=$1};1'` && \
 wget https://releases.hashicorp.com/terraform/${release}/terraform_${release}_linux_amd64.zip && \
 unzip terraform_${release}_linux_amd64.zip && \
 mv terraform /usr/bin/terraform

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
 install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
        chmod 700 get_helm.sh && \
        ./get_helm.sh

RUN wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash
