#!/bin/sh

# Ripped off from chromiumos/platform/init.git/tcsd.conf

if [ -e /sys/class/misc/tpm0/device/owned ]; then
  owned=$(cat /sys/class/misc/tpm0/device/owned || echo "")
  if [ "$owned" -eq "0" ]; then
    # Clean up any existing tcsd state.
    rm -rf /var/lib/tpm/*
  elif [ "$owned" -eq "1" ]; then
    # Already owned.
    # Check if trousers' system.data is size zero.  If so, then the TPM has
    # been owned already and we need to copy over an empty system.data to be
    # able to use it in trousers.
    if [ ! -f /var/lib/tpm/system.data ] ||
       [ ! -s /var/lib/tpm/system.data ]; then
      if [ ! -e /var/lib/tpm ]; then
        mkdir -m 0700 -p /var/lib/tpm
      fi
      umask 0177
      cp --no-preserve=mode /etc/trousers/system.data.auth \
        /var/lib/tpm/system.data
      umask 0133
      touch /var/lib/.tpm_owned
    fi
  fi
fi

/usr/sbin/tcsd
