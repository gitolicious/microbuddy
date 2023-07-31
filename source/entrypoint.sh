#!/bin/sh

if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Generating SSH key"
    ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa
fi

echo "SSH public key:"
cat ~/.ssh/id_rsa.pub

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

if [ ! -f ~/.ssh/known_hosts ]; then
    echo "Importing SSH host key of target"
    ssh-keyscan -H ${TARGET_IP} >> ~/.ssh/known_hosts
fi

echo "Setting up scheduled backup sync to ${TARGET_IP} every ${BACKUP_CRON}"
echo "${BACKUP_CRON} /scripts/backup.sh ${BACKUP_MASTERPASSWORD} > /dev/stdout" | crontab -

echo "Starting initial backup"
/scripts/backup.sh ${BACKUP_MASTERPASSWORD}

echo "Scheduling further backups by cron..."
/usr/sbin/crond -f
