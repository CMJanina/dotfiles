#!/bin/bash
# Adapted for Pibi from Bazzite DX, 2026-10-26.
set -eoux pipefail

mkdir -p /var/roothome /var/opt
cp -avf /ctx/system_files/. /
bash /ctx/trust.sh /ctx/cosign.pub

dnf5 install -y \
    android-tools \
    bcc \
    bpftop \
    bpftrace \
    ccache \
    flatpak-builder \
    git-subtree \
    google-noto-sans-fonts \
    nicstat \
    numactl \
    podman-machine \
    podman-tui \
    python3-ramalama \
    restic \
    rclone \
    sysprof \
    tiptop \
    usbmuxd \
    waypipe \
    zsh

dnf5 remove -y mesa-libOpenCL
dnf5 --setopt=install_weak_deps=False install -y \
    rocm-hip \
    rocm-opencl \
    rocm-clinfo \
    rocm-smi \
    qemu \
    libvirt \
    qemu-kvm \
    virt-manager \
    edk2-ovmf \
    guestfs-tools

dnf5 -y copr enable scottames/ghostty
dnf5 -y copr enable imput/helium

# Keep Qt 5 companions at the base image's locked Plasma versions.
qt5_packages=()
for package in plasma-breeze plasma-integration plasma-oxygen; do
    read -r version release arch signature <<< "$(rpm -q --qf '%{VERSION} %{RELEASE} %{ARCH} %{RSAHEADER:pgpsig}' "$package")"
    qt5_packages+=("https://kojipkgs.fedoraproject.org/packages/$package/$version/$release/data/signed/${signature: -8}/$arch/$package-qt5-$version-$release.$arch.rpm")
done
dnf5 --setopt=localpkg_gpgcheck=True install -y "${qt5_packages[@]}" ghostty helium-bin
dnf5 -y copr disable scottames/ghostty
dnf5 -y copr disable imput/helium

# Packages under /var/opt must live in /usr to survive image deployment.
mkdir -p /usr/lib/opt
for directory in /var/opt/*/; do
    [ -d "$directory" ] || continue
    name=$(basename "$directory")
    mv "$directory" "/usr/lib/opt/$name"
    echo "L+ /var/opt/$name - - - - /usr/lib/opt/$name" >> /usr/lib/tmpfiles.d/opt-fix.conf
done

systemctl enable podman.socket bazzite-dx-groups.service

echo 'import "/usr/share/ublue-os/just/95-bazzite-dx.just"' >> /usr/share/ublue-os/justfile

image_info=/usr/share/ublue-os/image-info.json
jq '."image-name" = "pibi" | ."image-vendor" = "pixelcmtd" | ."image-tag" = "latest" | ."image-ref" = "ostree-image-signed:docker://ghcr.io/pixelcmtd/pibi"' \
    "$image_info" > /tmp/image-info.json
mv /tmp/image-info.json "$image_info"
sed -i 's/^VARIANT_ID=.*/VARIANT_ID=pibi/' /usr/lib/os-release
sed -i \
    -e 's|^Website=.*|Website=https://github.com/pixelcmtd/dotfiles/tree/daddy/pibi|' \
    -e "s/^Variant=.*/Variant=Pixie's Bazzite Image/" \
    /etc/xdg/kcm-about-distrorc

kernel_version=$(rpm -q --queryformat='%{evr}.%{arch}' kernel)
dracut --no-hostonly --kver "$kernel_version" --reproducible --zstd --add ostree \
    -f "/usr/lib/modules/$kernel_version/initramfs.img"
chmod 0600 "/usr/lib/modules/$kernel_version/initramfs.img"

dnf5 clean all

# Refresh rpm-ostree's base database after the image's RPM transactions.
for file in rpmdb.sqlite rpmdb.sqlite-shm rpmdb.sqlite-wal; do
    target="/usr/share/rpm/$file"
    link_path="/usr/lib/sysimage/rpm-ostree-base-db/$file"
    if [[ -f $target && -f $link_path ]]; then
        ln -f "$target" "$link_path"
    fi
done

find /var -mindepth 1 -delete
mkdir -p /var/tmp
chmod 1777 /var/tmp
