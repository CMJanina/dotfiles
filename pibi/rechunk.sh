#!/bin/bash
set -euo pipefail

graphroot=$(podman info --format '{{.Store.GraphRoot}}')
podman run --rm --privileged --pull=never \
    --mount=type=image,src=localhost/pibi:latest,target=/rpm-ostree \
    --mount=type=bind,src="$graphroot",target=/run/host-container-storage \
    --mount=type=tmpfs,target=/run/rpm-ostree-storage \
    --entrypoint /usr/bin/rpm-ostree localhost/pibi:latest \
    compose build-chunked-oci --bootc --max-layers 128 --format-version 2 \
    --rootfs /rpm-ostree \
    --output 'containers-storage:[overlay@/run/host-container-storage+/run/rpm-ostree-storage]localhost/pibi:latest'
