#!/bin/ash

# https://www.baeldung.com/linux/rsync-encrypted-remote-backups

#===============================================================
# Constants
#===============================================================

LOOP=true # rsync loop, helpful with not stable internet connections, it can be true or false
SERVER=root@${TARGET_IP} # replace x.x.x.x with the remote server's IP or host name
BWLIMIT=0 # maximum transfer rate (kbytes/s), 0 means no limit

echo "rsync --bwlimit setted to $BWLIMIT kbytes/s (0 means no limit)"

ENCVIRDIR=/var/lib/microbuddy/encrypted # encrypted virtual read-only directory
LOCALDATA=/var/lib/microbuddy/data # local data to be backed up
REMOTEDIR=/var/lib/microbuddy/backups # dir in the remote server
ENCBACKUP=$SERVER:$REMOTEDIR  # rsync destination dir

PASSFILE=/var/lib/microbuddy/passwd

#===============================================================
# Arguments
#===============================================================

BACKUP_MASTERPASSWORD=$1
echo $BACKUP_MASTERPASSWORD > $PASSFILE
#===============================================================
# Set a trap for CTRL+C to properly exit
#===============================================================

trap "fusermount -u $ENCVIRDIR; rm -fR $ENCVIRDIR; echo CTRL+C Pressed!; read -p 'Press Enter to exit...'; exit 1;" SIGINT SIGTERM

#===============================================================
# Initial checks
#===============================================================

# rsync must be installed
if [ -z "$(which rsync)" ]; then
    echo "Error: rsync is not installed"
    exit 1
fi

# gocryptfs must be installed
if [ -z "$(which gocryptfs)" ]; then
    echo "Error: gocryptfs is not installed"
    exit 1
fi

#===============================================================
# Mount and rsync virtual encrypted directory
#===============================================================

mkdir -p $ENCVIRDIR

if find "$ENCVIRDIR" -mindepth 1 -maxdepth 1 | read; then
    echo "The encrypted virtual directory $ENCVIRDIR must be empty!"
    exit 1
fi

if find "$LOCALDATA" -mindepth 1 -maxdepth 1 | read; then
    echo "The unencrypted directory $LOCALDATA contains local data to be backed up..."
else
    echo "The unencrypted directory $LOCALDATA cannot be empty, it must contain local data to be backed up..."
    exit 1
fi

if test -f "$LOCALDATA/.gocryptfs.reverse.conf"; then
    echo "The unencrypted directory $LOCALDATA is already initialized for gocryptfs usage."
else
    echo "Initializing read-only encrypted view of the unencrypted directory $LOCALDATA,"
    echo "without encrypting file names and symlink (to allow the recovery of individual files)."
    gocryptfs -reverse -init -plaintextnames $LOCALDATA -passfile $PASSFILE -nosyslog
fi
echo "mount"
# mount read-only encrypted virtual copy of unencrypted local data:
if gocryptfs -ro -one-file-system -reverse -passfile $PASSFILE -nosyslog -exclude-wildcard img2.jpg $LOCALDATA $ENCVIRDIR; then
    echo "gocryptfs succeeded -> the decrypted dir $LOCALDATA is virtually encrypted in $ENCVIRDIR"
else
    echo "gocryptfs failed"
    exit 1
fi
echo mounted
while [ "true" ]
do

    # rsync local encrypted virtual copy of data to destination dir:
    if rsync --bwlimit=$BWLIMIT -P -a -z --delete $ENCVIRDIR/ $ENCBACKUP; then
        echo "rsync succeeded -> a full encrypted copy of $LOCALDATA is ready in $ENCBACKUP"
        break
    else
        if ! $LOOP; then
            echo "rsync failed"
            fusermount -u $ENCVIRDIR
            exit 1
        fi
    fi

    if ! $LOOP; then
        break
    fi

done

# unmount encrypted virtual copy of local data :
fusermount -u $ENCVIRDIR

# remove encrypted virtual directory
rm -fR $ENCVIRDIR

exit 0
