## Remote machine NixOS installation
```bash
export PASS= #Enter your password here
nix run nixpkgs#nixos-anywhere -- \
    --disk-encryption-keys /tmp/disk.key <(echo -n "$PASS") \
    --flake .#homeserver \
    --generate-hardware-config nixos-generate-config ./systems/homeserver/hardware.nix \
    root@192.168.0.210
```