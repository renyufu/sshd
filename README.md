# sshd
Docker image for ubuntu with sshd

# Usage

```
chmod 600 authorized_keys
docker run -d --name sshd -v `pwd`/authorized_keys:/home/test/.ssh/authorized_keys renyufu/sshd
```

