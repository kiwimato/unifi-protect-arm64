#!/bin/bash
set -e
cd download-bin-here

sudo apt-get update \
    && sudo apt-get -y install binwalk dpkg-repack dpkg

wget -O fwupdate.bin "$1"
sudo binwalk -e fwupdate.bin

dpkg-query --admindir=_fwupdate.bin.extracted/squashfs-root/var/lib/dpkg/ -W -f='${package} | ${Maintainer}\n' | grep -E "@ubnt.com|@ui.com" | cut -d "|" -f 1 > packages.txt

while read pkg; do
  # -d -Zxz will force the compression to xz instead of zstd because Debian 11 doesn't support it
  dpkg-repack -d -Zxz --root=_fwupdate.bin.extracted/squashfs-root/ --arch=arm64 ${pkg}
done < packages.txt

cp ubnt-archive-keyring* unifi-core* ubnt-tools* ulp-go* unifi-assets-unvr* ../put-deb-files-here/
cp extracted_fw/_fwupdate.bin.extracted/squashfs-root/usr/lib/version ../put-version-file-here/ 
