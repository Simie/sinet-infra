#!/bin/sh

# Sambda reports incorrect disk space due to the symlinks involved in personal share (it reports boot drive space instead)
# Instead, just report the free space available on the jbod_storage array as we don't want sambda to exceed that ever. (ignore SSD space as that's just a cache)

# Script adapted from https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html
df /mnt/jbod_storage | tail -1 | awk '{print $(NF-4),$(NF-2)}'
