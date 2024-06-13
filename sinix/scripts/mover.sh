#!/bin/sh   

# Moves files from the source directory (SSD cache) to the mass storage directory (HDDs)
# when they have not been modified for over 24 hours

# Adapted from https://unix.stackexchange.com/questions/693315/rsync-files-by-date

# Set source and destination directories
src=/mnt/tank/fuse/. # . at end indicates where relative paths end, i.e. ./something/nested/file.txt will move to /mnt/storage_jbod/something/nested/file.txt
dst=/mnt/jbod_storage

find "$src/" -type f -atime +1 -print0 |
    rsync -iv --archive --remove-source-files --prune-empty-dirs --files-from - --from0 / "$dst"
    