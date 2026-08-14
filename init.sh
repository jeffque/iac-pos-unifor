#!/bin/bash
mkdir .aws

if ! [ -f terraform/id_ed25519 ]; then
    ssh-keygen -f terraform/id_ed25519
fi