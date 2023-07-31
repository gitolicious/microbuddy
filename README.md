A minimal approach to store an encrypted backup at your buddy's location.

_⚠️ WORK IN PROGRESS ⚠️_
This project is in an early stage.

## Idea ##

Two docker containers (source and target) are connected via a ZeroTier network. The source mounts folders from the host, encrypts them on-the-fly and syncs them to the target.

## Credits ##

The concept of encrypted remote backups via rsync is based on this article: https://www.baeldung.com/linux/rsync-encrypted-remote-backups