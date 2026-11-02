# vim: set ft=make :

# Adapted for Pibi from Bazzite DX, 2026-10-28.
# Setup and configure virtualization and vfio
setup-virtualization ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    set -euo pipefail
    if [[ $(id -u) -eq 0 ]]; then
      echo "Please do not run this command as root"
      exit 1
    fi
    # Check if we are running on a Steam Deck
    if /usr/libexec/hwsupport/valve-hardware; then
      echo "${red}${b}WARNING${n}: Virtualization is not properly supported on Steam Deck by Valve"
      echo "Use at your own risk and performance may not be ideal."
    fi
    OPTION="{{ ACTION }}"
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-virtualization <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'virt-on' to select Enable Virtualization"
      echo "  Use 'group' to select Add $USER to libvirt group"
      echo "  Use 'vfio-on' to select Enable VFIO drivers"
      echo "  Use 'vfio-off' to select Disable VFIO drivers"
      echo "  Use 'kvmfr' to select Autocreate Looking-Glass shm"
      echo "  Use 'usbhp-on' to select Enable SPICE USB hot plugging"
      echo "  Use 'usbhp-off' to select Disable SPICE USB hot plugging"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Virtualization Setup${normal}"
      echo "NOTE: Enabling Virtualization configures libvirt permissions and hooks"
      OPTION=$(Choose \
        "Enable Virtualization" \
        "Add $USER to libvirt group" \
        "Enable VFIO drivers" \
        "Disable VFIO drivers" \
        "Enable kvmfr module" \
        "Enable USB hot plugging" \
        "Disable USB hot plugging" \
      )
    fi
    if [[ "${OPTION,,}" =~ (^enable[[:space:]]virtualization|virt-on) ]]; then
      sudo systemctl enable --now libvirtd
      sudo restorecon -rv /var/lib/libvirt
      sudo restorecon -rv /var/log/libvirt
      echo "Giving qemu access to read ISO files from $HOME"
      sudo setfacl -m u:qemu:rx "$HOME"
      sudo mkdir -p /etc/libvirt/hooks/qemu.d
      if sudo test ! -f "/etc/libvirt/hooks/qemu"; then
        echo "Adding libvirt qemu hooks"
        sudo wget 'https://raw.githubusercontent.com/PassthroughPOST/VFIO-Tools/master/libvirt_hooks/qemu' -O /etc/libvirt/hooks/qemu
        sudo chmod +x /etc/libvirt/hooks/qemu
      fi
      sudo systemctl enable bazzite-libvirtd-setup.service
      echo "libvirtd will be enabled at next reboot"
      echo 'Please reboot to apply changes'
    elif [[ "${OPTION,,}" =~ (^enable[[:space:]]vfio|vfio-on) ]]; then
      # Check if we are running on a Steam Deck
      if /usr/libexec/hwsupport/valve-hardware; then
        echo "IOMMU is not supported on Steam Deck"
        exit 0
      fi
      echo "Enabling VFIO..."
      CPU_VENDOR=$(grep "vendor_id" "/proc/cpuinfo" | uniq | awk -F": " '{ print $2 }')
      VENDOR_KARG="unset"
      if [[ ${CPU_VENDOR} == "AuthenticAMD" ]]; then
        VENDOR_KARG="amd_iommu=on"
      elif [[ ${CPU_VENDOR} == "GenuineIntel" ]]; then
        VENDOR_KARG="intel_iommu=on"
      fi
      if [[ ${VENDOR_KARG} == "unset" ]]; then
        echo "Failed to get CPU vendor, exiting..."
        exit 1
      else
        rpm-ostree initramfs --enable
        rpm-ostree kargs \
          --append-if-missing="${VENDOR_KARG}" \
          --append-if-missing="iommu=pt" \
          --append-if-missing="rd.driver.pre=vfio-pci" \
          --append-if-missing="vfio_pci.disable_vga=1"
        echo "VFIO will be enabled on next boot, make sure you enable IOMMU, VT-d or AMD-v in your BIOS!"
        echo "Please understand that since this is such a niche use case, support will be very limited!"
        echo 'Use the command "ls-iommu -grk" to get iommu information about your GPUs, use the "--help" flag for more options'
        echo ""
        echo "${b}Systems with multiple GPUs${n}"
        echo "Bind your unused/second GPU device ids to the vfio driver by running"
        echo 'rpm-ostree kargs --append-if-missing="vfio_pci.ids=xxxx:yyyy,xxxx:yyzz"'
        echo "You will require a $(Urllink "https://www.amazon.com/s?k=hdmi+displayport+dummy+plug" "Dummy HDMI/DisplayPort plug (Ghost Adapter)") or hook the GPU"
        echo "to a separate monitor input in order to turn the GPU on when starting the VM."
        echo "NOTE: Your second GPU should be as different as possible from your main GPU and will not be usable by the host after you bind it to the vfio driver!"
        echo ""
        echo "${b}Systems with 1 GPU${n}"
        echo "Once rebooted you can continue setting up whatever scripts and hooks you need"
        echo "to get Single GPU passthrough working, however ${u}you will be on your own${n}."
        echo "${b}Do not ask for support for setting up Single GPU Passthrough, we can not help you!${n}"
      fi
    elif [[ "${OPTION,,}" =~ (^disable[[:space:]]vfio|vfio-off) ]]; then
      # Check if we are running on a Steam Deck
      if /usr/libexec/hwsupport/valve-hardware; then
        echo "IOMMU is not supported on Steam Deck"
        exit 0
      fi
      echo ""
      echo "Make sure you have ${b}disabled autostart of all VMs using VFIO${n} before continuing!"
      CONFIRM=$(Choose Cancel Continue)
      if [ "$CONFIRM" == "Continue" ]; then
        echo "Disabling VFIO..."
        read -r -a KERNEL_ARGS <<< "$(rpm-ostree kargs)"
        REMOVE_ARGS=()
        for ARG in "${KERNEL_ARGS[@]}"; do
          case "$ARG" in
            vfio_pci.ids=*|kvmfr.static_size_mb=*) REMOVE_ARGS+=("--delete-if-present=$ARG") ;;
          esac
        done
        echo "Removing deprecated dracut modules"
        sudo rm -f /etc/dracut.conf.d/vfio.conf /etc/modprobe.d/kvmfr.conf
        rpm-ostree kargs \
        --delete-if-present="iommu=pt" \
        --delete-if-present="iommu=on" \
        --delete-if-present="amd_iommu=on" \
        --delete-if-present="intel_iommu=on" \
        --delete-if-present="rd.driver.pre=vfio-pci" \
        --delete-if-present="vfio_pci.disable_vga=1" \
        --delete-if-present="vfio_pci.disable_vga=0" \
        "${REMOVE_ARGS[@]}"
      fi
    elif [[ "${OPTION,,}" =~ kvmfr ]]; then
      sudo /usr/libexec/bazzite-dx-kvmfr-setup
    elif [[ "${OPTION,,}" =~ (^enable[[:space:]]usb|usbhp-on) ]]; then
      echo "Adding udev rule for USB devices"
      sudo bash -c 'cat << USBHP_UDEV > /etc/udev/rules.d/72-usbhp.rules
    ACTION=="add" SUBSYSTEM=="usb", TAG+="uaccess"
    USBHP_UDEV'
    elif [[ "${OPTION,,}" =~ (^disable[[:space:]]usb|usbhp-off) ]]; then
      sudo bash -c 'rm /etc/udev/rules.d/72-usbhp.rules'
    elif [[ "${OPTION,,}" =~ group ]]; then
      if ! grep -q "^libvirt" /etc/group; then
        grep '^libvirt' /usr/lib/group | sudo tee -a /etc/group > /dev/null
      fi
      sudo usermod -aG libvirt "$USER"
    else
      echo "Unknown option: $OPTION" >&2
      exit 1
    fi
