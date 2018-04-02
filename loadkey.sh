#!/usr/bin/env bash

set +x

{
  echo "-----BEGIN PGP PRIVATE KEY BLOCK-----"
  echo "${GPG_SECRET}" | fold -w65
  echo "-----END PGP PRIVATE KEY BLOCK-----"
} | gpg --import || true
