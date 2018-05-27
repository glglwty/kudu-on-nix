# Install Nix
```sh
curl https://nixos.org/nix/install | sh
. ~/.nix-profile/etc/profile.d/nix.sh
```
# Build kudu
Run under this repo:
```sh
nix-build
```
Kudu will be installed into the nix store and linked at ./result directory.
