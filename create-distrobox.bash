#!/usr/bin/env bash
set -euo pipefail

image=ghcr.io/comminutus/kube-dev
: "${TAG:=latest}"
name=kube-dev


distrobox rm --force "$name"
distrobox create -p -i "$image:$TAG" "$name"
distrobox enter --name "$name"
