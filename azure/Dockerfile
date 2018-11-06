FROM debian:jessie-slim

WORKDIR /azure

COPY * *

## Installing Azure-CLI and Docker CE
RUN sudo apt-get install azure-cli && \
    sudo apt-get remove docker docker-engine docker.io && \
    sudo apt-get update && \
    sudo apt-get install \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common &&\
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - &&\
    sudo apt-key fingerprint 0EBFCD88 && \
    sudo add-apt-repository \
            "deb [arch=amd64] https://download.docker.com/linux/debian \
            $(lsb_release -cs) \
            stable" && \
    sudo apt-get update && \
    sudo apt-get install docker-ce &&\
    sudo groupadd docker && \
    sudo usermod -aG docker $USER &&\
    # This is for test reason so you can remove if all the instruction above succeed
    docker run hello-world && \
    pwd

## Installing Docker Machine
RUN base=https://github.com/docker/machine/releases/download/v0.14.0 && \
    curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine && \
    sudo install /tmp/docker-machine /usr/local/bin/docker-machine
    
CMD ["/bin/bash","azure-run.sh"]
#CMD ["/bin/bash","../startup.sh"]



    
