FROM ghcr.io/comminutus/base-shell-env:v1.1.0

WORKDIR "$HOME"

COPY install-packages.bash .

RUN ./install-packages.bash && rm ./install-packages.bash
