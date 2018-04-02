#!/usr/bin/env bash

set +x

{
  echo "-----BEGIN PGP PRIVATE KEY BLOCK-----"
  echo ""
  echo "${GPG_SECRET}" | fold -w64
  echo "-----END PGP PRIVATE KEY BLOCK-----"
} | gpg --import || true
