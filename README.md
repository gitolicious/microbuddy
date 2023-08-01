µBuddy (MicroBuddy or MyBuddy) is a minimal approach to store an encrypted backup of your data at your buddy's location.

_⚠️ WORK IN PROGRESS ⚠️_
This project is in an early stage, expect a bumpy ride.

## Idea ##

Two docker containers (source and target) are connected via a ZeroTier network. The source mounts folders from your host system, encrypts them on-the-fly and syncs them to the target.

## How to run ##

### Setup ###

For initial setup, we need to break the chicken and egg problem of connection and authentication.

* Register and set up a private ZeroTier network at https://my.zerotier.com/.
* Use the network ID as NETWORK_ID in both `{source|target}/docker-compose.yaml` files.
* Generate a secure password as `BACKUP_MASTERPASSWORD` and configure the backup schedule as `BACKUP_CRON` in the `target/docker-compose.yaml`.
* Launch the source container, check the SSH public key printed in the logs, copy the full line and use it as `SSH_AUTHORIZED_KEY` in `target/docker-compose.yaml`. Note down the ZeroTier address. Ignore the rest for now.
* Send the `target/docker-compose.yaml` file to your buddy have them start it.
* Back at the ZeroTier admin UI, open your network. There are now two entries in the _Members_ section. For extra security, verify the addresses to match your and your buddy's addresses shown in the Docker logs. Activate the _☑️ Auth_ checkbox, give an appropriate name (_"source"_/_"target"_) and not down the target's _Managed IP_.
* Configure the `source/docker-compose.yaml` with the target's ZeroTier IP as `TARGET_IP`.
* Restart the source container.

Now everything is set up for the backup. The target will accept SSH connections from the source. Upon initial connection, the target's host key will be automatically accepted and verified in the future.

### Get backup master key ###

For disaster recovery, you should note down the master key in a secure place.

```bash
docker exec -it microbuddy-source ./gocryptfs-xray -dumpmasterkey  /var/lib/microbuddy/data/.gocryptfs.reverse.conf
```

### Restore ###

c.f. [Full Restore](https://www.baeldung.com/linux/rsync-encrypted-remote-backups#3-full-restore) and [Single File Restore](https://www.baeldung.com/linux/rsync-encrypted-remote-backups#4-single-file-restore)

Run the commands inside the source container.

## Credits ##

The concept of encrypted remote backups via rsync is based on this article: https://www.baeldung.com/linux/rsync-encrypted-remote-backups