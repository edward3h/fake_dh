#!/bin/bash

SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SHARE="$SOURCE_DIR/../dockershare"
mkdir -p "$SHARE/home/theuser/.ssh"
mkdir -p "$SHARE/etc/authorized_keys"
mkdir -p "$SHARE/etc/ssh"

HOME="$SHARE/home/theuser"
TYPE=ecdsa
ID="id_$TYPE"

if [ ! -f "$HOME/.ssh/$ID" ]; then
    ssh-keygen -m pem -t "$TYPE" -f "$HOME/.ssh/$ID" -N ""
    chmod 600 "$HOME/.ssh/$ID"* 
fi

if [ ! -f "$SHARE/etc/authorized_keys/theuser" ] || [ "$HOME/.ssh/$ID.pub" -nt "$SHARE/etc/authorized_keys/theuser" ]; then
    cp "$HOME/.ssh/$ID.pub" "$SHARE/etc/authorized_keys/theuser"
fi