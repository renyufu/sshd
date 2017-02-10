FROM       ubuntu:16.04
MAINTAINER REN yufu "https://github.com/renyufu"

RUN apt-get update
RUN apt-get install -y openssh-server

RUN mkdir /var/run/sshd
RUN sed -ri 's/UsePAM yes/#UsePAM/g' /etc/ssh/sshd_config
RUN sed -ri 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

RUN echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config
RUN echo "GatewayPorts yes" >> /etc/ssh/sshd_config

EXPOSE 22
RUN useradd test -m
RUN usermod -p `head -c12 /dev/urandom |base64` test
RUN chmod 700 /home/test
RUN mkdir /home/test/.ssh
RUN chown test.test /home/test/.ssh
RUN chmod 700 /home/test/.ssh
ADD authorized_keys /home/test/.ssh/
RUN chown test.test /home/test/.ssh/authorized_keys
RUN chmod 600 /home/test/.ssh/authorized_keys
VOLUME /home/test/.ssh
RUN ssh-keygen -A

CMD ["/usr/sbin/sshd", "-D"]
