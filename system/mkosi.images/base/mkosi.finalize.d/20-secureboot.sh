#!/bin/bash
set -e

# build keys for /loader/keys/
# two sets: 'astros' for our own custom keys only and 'astros+microsoft' for our own custom keys plus the Microsoft DB/KEK certs.

KEY="$SRCDIR/mkosi.key"
CRT="$SRCDIR/mkosi.crt"
OBJECTS="$SRCDIR/mkosi.images/base/submodules/AstrOS_secureboot_objects/PreSignedObjects"
KEYS="$BUILDROOT/boot/loader/keys"

ASTROS_UUID="646273a4-e591-4e0a-8e3f-2eb6c106c5f8"
MICROSOFT_UUID="77fa9abd-0359-4d32-bd60-28f4e78f784b"
ATTR="NON_VOLATILE,BOOTSERVICE_ACCESS,RUNTIME_ACCESS,TIME_BASED_AUTHENTICATED_WRITE_ACCESS"

# check if mkosi.key and mkosi.crt exist
if [[ ! -f "$KEY" || ! -f "$CRT" ]]; then
  echo "mkosi.key and mkosi.crt not found" >&2
  exit 0
fi

# temp dir, gets deleted on any exit
WORK="$(mktemp --directory)"
trap 'rm -rf "$WORK"' EXIT

# convert from PEM to DER
openssl x509 -outform DER -in "$CRT" -out "$WORK/astros.der"
sbsiglist --owner "$ASTROS_UUID" --type x509 --output "$WORK/astros.esl" "$WORK/astros.der"

# generate microsoft.db/KEK.esl
for cert in "$OBJECTS"/DB/Certificates/*.der; do
  sbsiglist --owner "$MICROSOFT_UUID" --type x509 --output "$WORK/ms.esl" "$cert"
  cat "$WORK/ms.esl" >>"$WORK/microsoft.db.esl"
done

for cert in "$OBJECTS"/KEK/Certificates/*.der; do
  sbsiglist --owner "$MICROSOFT_UUID" --type x509 --output "$WORK/ms.esl" "$cert"
  cat "$WORK/ms.esl" >>"$WORK/microsoft.KEK.esl"
done

# the PK is always only ours, the Microsoft certs are added to db and KEK when the name matches
for name in astros astros+microsoft; do
  cp "$WORK/astros.esl" "$WORK/db.esl"
  cp "$WORK/astros.esl" "$WORK/KEK.esl"

  if [[ "$name" == "astros+microsoft" ]]; then
    cat "$WORK/microsoft.db.esl" >>"$WORK/db.esl"
    cat "$WORK/microsoft.KEK.esl" >>"$WORK/KEK.esl"
  fi

  mkdir --parents "$KEYS/$name"
  sbvarsign --attr "$ATTR" --key "$KEY" --cert "$CRT" --output "$KEYS/$name/PK.auth" PK "$WORK/astros.esl"
  sbvarsign --attr "$ATTR" --key "$KEY" --cert "$CRT" --output "$KEYS/$name/KEK.auth" KEK "$WORK/KEK.esl"
  sbvarsign --attr "$ATTR" --key "$KEY" --cert "$CRT" --output "$KEYS/$name/db.auth" db "$WORK/db.esl"
done
