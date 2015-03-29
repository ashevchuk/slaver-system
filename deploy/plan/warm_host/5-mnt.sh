cd /etc
sed -i 's/ errors=remount-ro/noatime,sync,dirsync,norelatime,journal_checksum,barrier=1,user_xattr,auto_da_alloc,nodiscard,i_version,errors=remount-ro/' ./fstab
