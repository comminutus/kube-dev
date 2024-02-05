# kube-dev
[![AGPL License](https://img.shields.io/badge/license-AGPL-blue.svg)](https://www.gnu.org/licenses/agpl-3.0.html)
[![CI](https://github.com/comminutus/kube-dev/actions/workflows/ci.yaml/badge.svg)](https://github.com/comminutus/kube-dev/actions/workflows/ci.yaml)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/comminutus/kube-dev)](https://github.com/comminutus/kube-dev/releases/latest)


## Description
`kube-dev` is a container image to be used as a shell for development with Kubernetes, particularly when using [FluxCD](https://fluxcd.io/), [Fedora CoreOS](https://fedoraproject.org/coreos/) and [Terraform](https://www.terraform.io/). 

## Features
- [CoreOS Butane](https://github.com/coreos/butane)
- [direnv](https://github.com/direnv/direnv)
- [FluxCD](https://fluxcd.io/)
- [krew](https://github.com/kubernetes-sigs/krew)
  Plugins:
    - [ctx/nx](https://github.com/ahmetb/kubectx)
- [kubectl](https://github.com/kubernetes/kubectl)
- [Helm](https://github.com/helm/helm)
- [Mozilla SOPS](https://github.com/getsops/sops)
- [pass](https://www.passwordstore.org/)
- [Terraform](https://www.terraform.io/)
- [yq](https://github.com/mikefarah/yq)
- [ytt](https://github.com/carvel-dev/ytt)

## Getting Started

### Prerequisites

You must have a container runtime installed, like [Podman](https://github.com/containers/podman)(preferred) or [Docker](https://github.com/docker-library/docker).

## Usage

Pull down the image and use it directly with Distrobox or Toolbox:
```
podman pull ghcr.io/comminutus/kube-dev
distrobox create -i comminutus/kube-dev
distrobox enter kube-dev
```

## License

This project is licensed under the GNU Affero General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
