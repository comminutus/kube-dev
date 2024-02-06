ARG BASE_IMAGE=ghcr.io/comminutus/base-shell-env
ARG BASE_TAG=v0.2.2
FROM ${BASE_IMAGE}:${BASE_TAG}

# dnf-plugins-core required to add HashiCorp repo
RUN dnf install -y dnf-plugins-core

# Add HashiCorp repo
RUN dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo

# dnf packages
RUN dnf install -y      \
    butane              \
    coreos-installer    \
    direnv              \
    gettext             \
    make                \
    pass                \
    terraform

# yq (like jq, but for yaml)
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq &&  \
    chmod +x /usr/local/bin/yq
    
# ytt (YAML templating tool: https://carvel.dev/ytt/)
RUN wget https://github.com/carvel-dev/ytt/releases/latest/download/ytt-linux-amd64 -O /usr/local/bin/ytt &&  \
    chmod +x /usr/local/bin/ytt

# kubectl
RUN export K8S_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt);          \
    curl -LO https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl   &&  \
    curl -LO https://dl.k8s.io/${K8S_VERSION}/bin/linux/amd64/kubectl.sha256    &&  \    
    echo $(cat kubectl.sha256)  kubectl | sha256sum --check
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
RUN rm kubectl.sha256 kubectl

# helm
RUN get_helm_script="$(mktemp -q)" && \
    curl -fsSL -o "$get_helm_script" https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 "$get_helm_script" && \
    "$get_helm_script" && \
    rm "$get_helm_script" && \
    helm completion bash > /etc/bash_completion.d/helm

# Mozilla SOPS
RUN export SOPS_VERSION=$(curl -s https://api.github.com/repos/getsops/sops/tags | jq -r '[.[] | select(.name | contains("rc") | not)][0].name' | cut -c 2-); \
    export SOPS_RPM_FILENAME=sops-${SOPS_VERSION}.$(uname -m).rpm && \
    wget https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/${SOPS_RPM_FILENAME} && \
    dnf install -y $SOPS_RPM_FILENAME && \
    rm $SOPS_RPM_FILENAME

# flux
RUN curl -s https://fluxcd.io/install.sh | sudo bash

# krew
RUN export HOME=/opt/krew                                                                                       &&  \
    mkdir -p $HOME                                                                                              &&  \
    set -x; export KREW_TEMP=$(mktemp -d); cd ${KREW_TEMP}                                                      &&  \
    export OS="$(uname | tr '[:upper:]' '[:lower:]')"                                                           &&  \
    export ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"  &&  \
    export KREW="krew-${OS}_${ARCH}"                                                                            &&  \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"               &&  \
    tar zxvf "${KREW}.tar.gz"                                                                                   &&  \
    ./"${KREW}" install krew                                                                                    &&  \
    rm -rf $KREW_TEMP

# krew plugins
RUN export HOME=/opt/krew;  \
    export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"; \
    kubectl krew install    \
    ctx                     \
    ns

RUN ln -sL /opt/krew/.krew/bin/* /usr/local/bin/
RUN chmod 755 -R /opt/krew

# cleanup
RUN dnf clean all 