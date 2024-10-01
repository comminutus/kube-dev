#!/usr/bin/env bash
set -euo pipefail

arch="$(uname -m)"

packages=(
    butane
    coreos-installer
    helm
    kubernetes-client
    tofu
)

# Add OpenTofu repository
cat >/etc/yum.repos.d/opentofu.repo <<EOF
[opentofu]
name=opentofu
baseurl=https://packages.opentofu.org/opentofu/tofu/rpm_any/rpm_any/\$basearch
repo_gpgcheck=0
gpgcheck=1
enabled=1
gpgkey=https://get.opentofu.org/opentofu.gpg
       https://packages.opentofu.org/opentofu/tofu/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300

[opentofu-source]
name=opentofu-source
baseurl=https://packages.opentofu.org/opentofu/tofu/rpm_any/rpm_any/SRPMS
repo_gpgcheck=0
gpgcheck=1
enabled=1
gpgkey=https://get.opentofu.org/opentofu.gpg
       https://packages.opentofu.org/opentofu/tofu/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
EOF

# Upgrade built-in packages
dnf update -y
dnf upgrade -y

# Install missing packages
dnf install -y "${packages[@]}"

# Mozilla SOPS
sops_version="$(curl -s https://api.github.com/repos/getsops/sops/tags | jq -r '[.[] | select(.name | contains("rc") | not)][0].name' | cut -c 2-)"
sops_download_url="$(curl -s "https://api.github.com/repos/getsops/sops/releases/tags/v${sops_version}" | grep -oP '"browser_download_url": "\K[^"]*' | grep "sops-${sops_version}.*${arch}" | sort -r | head -n 1)"
sops_rpm_filename="$(basename "$sops_download_url")"
wget -q "$sops_download_url"
dnf install -y "$sops_rpm_filename"
rm "$sops_rpm_filename"

# FluxCD
curl -s https://fluxcd.io/install.sh | sudo bash

# krew
#export HOME=/opt/krew                                                                                       &&  \
mkdir -p /opt/krew
os="$(uname | tr '[:upper:]' '[:lower:]')"
krew_arch="$(echo "$arch" | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
krew_base_filename="krew-${os}_${krew_arch}"
krew_temp="$(mktemp -d)"
wget -q -P "$krew_temp" "https://github.com/kubernetes-sigs/krew/releases/latest/download/${krew_base_filename}.tar.gz"
tar zxvf "$krew_temp/${krew_base_filename}.tar.gz" -C "$krew_temp"
HOME=/opt/krew "$krew_temp/$krew_base_filename" install krew
rm -rf "$krew_temp"

# krew plugins
HOME=/opt/krew PATH="/opt/krew/.krew/bin:$PATH" kubectl krew install \
     ctx    \
     ns

ln -sL /opt/krew/.krew/bin/* /usr/local/bin/
chmod 755 -R /opt/krew

# Cleanup packages
dnf clean all

