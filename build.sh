#!/usr/bin/env bash

set -eux
set -o pipefail

GPG_PASSFILE=(/dev/shm/pass.*)

export DEBSIGN_PROGRAM="gpg --no-tty --trusted-key 0x7D1110294E694719 --passphrase-file ${GPG_PASSFILE[0]}"

# derive the useful kernel via installed files, sure
kernelver=(/boot/vmlinuz-*-generic)
kernelver=${kernelver#/boot/vmlinuz-}

srcdir=$(pwd)

iomem_ball=(iomemory-vsl-*.tar.gz)
iomem_extract=$(mktemp -d)

tar xf "${iomem_ball[0]}" --strip-components=4 -C "${iomem_extract}"
sudo cp -a "${iomem_extract}"/iomemory-* /usr/src
rm -rf "${iomem_extract}"

# move the dkms.conf.example to dkms.conf
tgt=(/usr/src/iomemory-*)
sudo mv /usr/src/iomemory-*/dkms.conf.example "${tgt[0]}"/dkms.conf

# the above actually set up local dkms. shuffle _again_ for dkms2ppa
dkms2ppa_root=$(mktemp -d)
dkms2ppa_dir="${dkms2ppa_root}/iomemory-vsl"
mkdir -p "${dkms2ppa_dir}"

iomem_deb_extract=$(mktemp -d)
tar xf "${iomem_ball[0]}" --strip-components=1 -C "${iomem_deb_extract}"
sudo cp -a "${iomem_deb_extract}"/debian "${dkms2ppa_dir}/iomemory-vsl-debian"
sudo cp -a "${tgt[0]}" "${dkms2ppa_dir}/iomemory-vsl"

cd "${dkms2ppa_dir}"
"${srcdir}/vendor/com.github.zedtux.dkms2ppa/dkms2ppa" ppa:notarrjay/fio-dkms xenial hewt1ojkif@gmail.com
