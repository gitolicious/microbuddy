#!/bin/sh
if [ ! -f /root/.ssh/host_key/ssh_host_rsa_key ]; then
    echo "Generating SSH host keys"
    ssh-keygen -q -N "" -t rsa -b 4096 -f /root/.ssh/host_key/ssh_host_rsa_key
fi

echo "SSH host keys:"
ssh-keygen -l -f /root/.ssh/host_key/ssh_host_rsa_key.pub

if [ ! -z "${SSH_AUTHORIZED_KEY}" ]; then
    echo "Allowing SSH key for $(echo ${SSH_AUTHORIZED_KEY} | awk '{print $NF}')"
    echo ${SSH_AUTHORIZED_KEY} >> /root/.ssh/authorized_keys
fi

echo "Allowed SSH users:"
cat /root/.ssh/authorized_keys | wc -l

echo "Starting SSH Server"
/usr/sbin/sshd

echo "Starting ZeroTier"
zerotier-one -d

echo "Giving ZeroTier some time to start up..."
sleep 5

if [ ! -z "${NETWORK_ID}" ]; then
    echo "Joining network ${NETWORK_ID}"
    zerotier-cli join ${NETWORK_ID}
fi

echo "Giving ZeroTier some time to connect..."
sleep 5

echo "ZeroTier status:"
zerotier-cli status
zerotier-cli listnetworks

echo "Keeping ZeroTier running"
while true; do
  sleep 1
done
