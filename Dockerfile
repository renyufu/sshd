FROM       ubuntu:16.04
MAINTAINER REN yufu "https://github.com/renyufu"

RUN apt-get update
RUN apt-get install -y openssh-server

RUN mkdir /var/run/sshd
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config
RUN echo "GatewayPorts yes" >> /etc/ssh/sshd_config

EXPOSE 22
RUN useradd test -m
USER test
VOLUME /home/test/.ssh

CMD    ["/usr/sbin/sshd", "-D"]
