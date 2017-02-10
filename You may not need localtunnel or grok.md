# [origin link](https://blog.rodneyrehm.de/archives/38-You-may-not-need-localtunnel-or-ngrok.html)

# Configuring sshd
  
  Let's first check if we even need to configure anything at all. Connect to your server ($server) and with privileges (su or sudo) run the following command:

```
sshd -T | grep -E 'gatewayports|allowtcpforwarding'
```
  the output looks like this (with yes and no depending on your current configuration):

```
gatewayports no
allowtcpforwarding yes
```

  We need to make sure both values are set to yes in the sshf config file - usually located at /etc/ssh/sshd_config, or /etc/sshd_config if you're on a Mac.

# User-Specific sshd Configuration

  You can limit the privilege of port forwarding to your own user by using a Match User statement:

```
# allow reverse tunneling only to the user rrehm
Match User rrehm
  AllowTcpForwarding yes
  GatewayPorts yes
```

  To verify the configuration specific to your user, run the following command providing your username and port to bind. The other options don't really matter, unless you've added more limitations to Match (see Limit access to openssh features with the Match option for inspiration).

```
user=rrehm
port=12345
sshd -T \
  -C user=${user} \
  -C host=* \
  -C addr=* \
  -C laddr=* \
  -C lport=${port} | grep -E 'gatewayports|allowtcpforwarding'
```

  again, this should output

```
gatewayports yes
allowtcpforwarding yes
Opening SSH Reverse Tunnels
```

  With sshd configured, all we need to do is tell ssh which port we want mapped:

```
user=rrehm
server=example.org
remotePort=1234
localPort=80
ssh ${user}@${server} -R ${remotePort}:localhost:${localPort}
```

  If you only want to bind the ports but not actually have a shell opened, add -N:

```
ssh ${user}@${server} -N -R ${remotePort}:localhost:${localPort}
```

  when you're done, Control C will terminate the SSH connection and your local server will no longer be available remotely.

# Making SSH Reverse Tunnels Reconnect Automatically

  If you want your tunnel(s) to automatically reconnect (when switching WiFis, for example), have a look at autossh (available via brew install autossh):

```
#!/bin/bash

# it's usually a good idea to exit upon error
set -e

# your connection parameters
user=rrehm
server=example.org
remotePort=1234
localPort=80

# some stuff autossh needs to know
AUTOSSH_SERVER_ALIVE_INTERVAL=30
AUTOSSH_SERVER_ALIVE_COUNT=2
export AUTOSSH_POLL=30
export AUTOSSH_GATETIME=0
export AUTOSSH_LOGFILE="/tmp/autossh.log"

# clean up log file on start
touch "${AUTOSSH_LOGFILE}"
rm "${AUTOSSH_LOGFILE}" || true

autossh -f -M 0 \
  -o "ExitOnForwardFailure yes" \
  -o "ServerAliveInterval ${AUTOSSH_SERVER_ALIVE_INTERVAL}" \
  -o "ServerAliveCountMax ${AUTOSSH_SERVER_ALIVE_COUNT}" \
  -A ${user}@${server} \
  -R ${remotePort}:localhost:${localPort}
```

# Conclusion

  You can expose local services on your remote servers, given you have a server you can SSH to. Using autossh the tunnel can be re-established automatically when it collapses. While this solves most of my personal problems, it is still inferior to ngrok. The vanilla SSH approach knows nothing about the protocols in use. It simply forwards a port, regardless of the service (HTTP, MySQL, SMTP, …). With a simple ngrok http 8080 you'll have remote access to your local webserver through HTTP and HTTPS - even if your local webserver only sports HTTP.
