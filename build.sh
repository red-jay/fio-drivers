#!/usr/bin/env bash

set -eux
set -o pipefail

GPG_PASSFILE=(/dev/shm/pass.*)

printf 'DEBSIGN_PROGRAM="gpg --no-use-agent --no-tty --trusted-key 0x7D1110294E694719 --passphrase-file %s"\nDEBSIGN_KEYID=%s\n' "${GPG_PASSFILE[0]}" "0x7D1110294E694719" > "${HOME}/.devscripts"

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

# patch makefile
pushd "${tgt[0]}" && patch -p1 < "${srcdir}/Makefile.patch" && popd

# build
. /usr/src/iomemory-*/dkms.conf
sudo dkms add   -m iomemory-vsl -v "${PACKAGE_VERSION}" -k "${kernelver}"
sudo dkms build -m iomemory-vsl -v "${PACKAGE_VERSION}" -k "${kernelver}"
sudo dkms mkdeb -m iomemory-vsl -v "${PACKAGE_VERSION}" -k "${kernelver}"

# the above actually set up local dkms. shuffle _again_ for dkms2ppa
dkms2ppa_root=$(mktemp -d)
dkms2ppa_dir="${dkms2ppa_root}/iomemory-vsl"
mkdir -p "${dkms2ppa_dir}"

iomem_deb_extract=$(mktemp -d)
tar xf "${iomem_ball[0]}" --strip-components=1 -C "${iomem_deb_extract}"
sudo cp -a "${iomem_deb_extract}"/debian "${dkms2ppa_dir}/iomemory-vsl-debian"
sudo cp -a "${tgt[0]}" "${dkms2ppa_dir}/iomemory-vsl"

cd "${dkms2ppa_dir}"
"${srcdir}/vendor/com.github.zedtux.dkms2ppa/dkms2ppa" ppa:notarrjay/fio-dkms "RJ Bergeron" "hewt1ojkif@gmail.com" xenial

# publish apt repo
cd "${srcdir}"

apt-get -qq update && apt-get -qq -y install git
git branch --track gh-pages remotes/origin/gh-pages
gh_pages=$(mktemp -d)
git clone -b gh-pages "file://$(pwd)/.git" "${gh_pages}"

cd "${gh_pages}"
git config user.email "hhewt1ojkif@gmail.com"
git config user.name "RJ Bergeron"
mkdir -p dists/fio/release/binary-amd64
apt-ftparchive packages pool > dists/fio/release/binary-amd64/Packages
apt-ftparchive release "-c=${srcdir}/aptftp.conf" dists/fio >dists/fio/Release
. "${HOME}/.devscripts"
${DEBSIGN_PROGRAM} -bao dists/fio/Release.gpg dists/fio/Release
git add *
git commit -a -m "updated via CI build"
git push

# back to the real checkout here
cd "${srcdir}"
git push origin gh-pages
