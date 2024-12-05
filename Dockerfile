FROM ubuntu:24.04
WORKDIR /mnt

ARG SERVER_USER=defaultuser
ARG SERVER_PASSWORD=defaultpassword

RUN apt update && \
    apt install -y tree nano vim openssh-server python3 python3-venv python3-pip sshpass vim sudo rsync wget && \
    mkdir /run/sshd && \
    wget https://download.java.net/java/GA/jdk22.0.1/c7ec1332f7bb44aeba2eb341ae18aca4/8/GPL/openjdk-22.0.1_linux-x64_bin.tar.gz && \
    tar -xvf openjdk-22.0.1_linux-x64_bin.tar.gz -C /opt && \
    rm openjdk-22.0.1_linux-x64_bin.tar.gz && \
    apt clean

ENV JAVA_HOME=/opt/jdk-22.0.1
ENV PATH=$JAVA_HOME/bin:$PATH

RUN python3 -m venv /opt/venv && \
    . /opt/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install ansible

ENV PATH="/opt/venv/bin:$PATH"

RUN useradd -m ${SERVER_USER} && \
    echo "${SERVER_USER}:${SERVER_PASSWORD}" | chpasswd && \
    echo "${SERVER_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    ssh-keygen -A

CMD ["/usr/sbin/sshd", "-D"]