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
