# vim: set ft=make :

# Adapted for Pibi from Bazzite DX, 2026-10-26.
# Configure virtualization and serial permissions.
[group('system')]
dx-group:
    #!/usr/bin/pkexec bash
    append_group() {
        local group_name="$1"
        if ! grep -q "^$group_name:" /etc/group; then
            echo "Appending $group_name to /etc/group"
            grep "^$group_name:" /usr/lib/group | sudo tee -a /etc/group > /dev/null
        fi
    }

    GROUPS_ADD=("libvirt" "dialout")

    for GROUP_ADD in "${GROUPS_ADD[@]}" ; do
        append_group $GROUP_ADD
        usermod -aG $GROUP_ADD {{ `id -un` }}
    done

    echo "Reboot system and log back in to use libvirt and serial connections."

# Install Pibi's system Flatpaks after rebasing.
install-flatpaks:
    #!/usr/bin/bash
    set -euo pipefail
    flatpak remote-add --system --if-not-exists flathub /etc/flatpak/remotes.d/flathub.flatpakrepo
    flatpak remote-modify --system --enable flathub
    xargs --no-run-if-empty --arg-file=/etc/ublue-os/system_flatpaks \
        flatpak install --system --assumeyes --noninteractive --or-update flathub
    ujust install-sayso
    ujust install-sidra

# Install Sayso's upstream Flatpak bundle.
install-sayso:
    #!/usr/bin/bash
    set -euo pipefail
    bundle=$(mktemp --suffix=.flatpak)
    trap 'rm -- "$bundle"' EXIT
    curl -fL -o "$bundle" https://github.com/watzon/sayso/releases/download/v0.14.1/sayso-0.14.1-linux-x86_64.flatpak
    printf '%s  %s\n' c185b5bebc9e2d6f5235dcd362a6bed50f11fd3e7da699cfa20714df27c77d59 "$bundle" | sha256sum --check
    flatpak install --system -y --noninteractive --or-update "$bundle"

# Install Sidra's upstream Flatpak bundle.
install-sidra:
    #!/usr/bin/bash
    set -euo pipefail
    bundle=$(mktemp --suffix=.flatpak)
    trap 'rm -- "$bundle"' EXIT
    curl -fL -o "$bundle" https://github.com/wimpysworld/sidra/releases/download/1.2.1/Sidra-1.2.1-linux-x86_64.flatpak
    printf '%s  %s\n' d27b7bb86fd584962d26c30ad3014880a7162c3270b28bf5576b67f0fc1384ee "$bundle" | sha256sum --check
    flatpak remote-add --system --if-not-exists flathub /etc/flatpak/remotes.d/flathub.flatpakrepo
    flatpak install --system -y --noninteractive flathub org.freedesktop.Platform//26.08
    flatpak install --system -y --noninteractive --or-update "$bundle"
