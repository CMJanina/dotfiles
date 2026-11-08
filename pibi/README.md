# Pibi

Based on `ghcr.io/ublue-os/bazzite:testing`, with DX development/ROCm tools,
Linux VMs and GPU passthrough, Ghostty, Helium and Podman. KDE desktop, without
Gaming Mode defaults.

AMDGPU uses `runpm=0` to keep the GPU awake when the KVM switches away. This can
increase idle power use.

## Build and publish

From `pibi/`:

```sh
podman build --pull --tag localhost/pibi:latest --file Containerfile .
```

CI builds PRs and publishes `ghcr.io/pixelcmtd/pibi:latest` daily and on
relevant pushes to `daddy`. One-time signing setup:

```sh
cosign generate-key-pair
gh secret set SIGNING_SECRET < cosign.key
gh secret set COSIGN_PASSWORD
```

Commit `cosign.pub`, keep `cosign.key` private, and make the GHCR package
public. Builds require the public key. `cosign` is in the base Brewfile.

## Switch

After the first publication:

```sh
sudo bash ./trust.sh cosign.pub &&
  sudo rpm-ostree uninstall ghostty helium-bin &&
  brh rebase ostree-image-signed:docker://ghcr.io/pixelcmtd/pibi:latest &&
  sudo systemctl reboot
```

Run this on the PC where you generated the key. It trusts that local public key
for Pibi and requires its signature for the rebase and updates. One reboot.
VSCodium comes from `pikd/Brewfile`, its extensions from `kilobase/Brewfile`.

After rebooting, install the Flatpak defaults:

```sh
ujust install-flatpaks
```

## Sayso

`ujust install-flatpaks` includes Sayso. Run `ujust install-sayso` to install it
separately. Launch Sayso, download a speech model, and use Ctrl+Alt+Space.
Version 0.14.1 is pinned; `flatpak update` cannot update its upstream bundle.

## Sidra

`ujust install-flatpaks` includes Sidra. Run `ujust install-sidra` to install it
separately, then launch Sidra and sign in to Apple Music. Version 1.2.1 is
pinned; `flatpak update` cannot update its upstream bundle.

## Java Web Start

Run `javaws path/to/file.jnlp`. Fedora provides IcedTea-Web; Adoptium's RPM
repository provides Temurin 8 and the Java 21 dependency. The launcher selects
Java 8 without changing the default Java. Image builds install current package
versions.

## VM setup

If the machine still needs virtualization and GPU passthrough configured:

```sh
ujust setup-virtualization virt-on
ujust setup-virtualization vfio-on
```

Follow the helper's device-binding instructions, then reboot. Existing VM
configuration carries over when rebasing.

## Sources

Adapted from
[Bazzite DX](https://github.com/ublue-os/bazzite-dx/tree/234a088181d9fdf7febcf9cdc8dc7d41e2969748)
and
[image-template](https://github.com/ublue-os/image-template/tree/d280996230fe87f6876d92acc352a0e0e288aaaf).
[Apache 2.0](LICENSE). DX configuration changes need to be copied manually.
