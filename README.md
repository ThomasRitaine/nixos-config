# nixos-config

My modular NixOS configuration for my VPS and laptop

## Apply a NixOS config

``` bash
sudo nixos-rebuild switch --flake ".#configName"
```

## Apply a home-manager config

``` bash
home-manager switch --flake ".#configName"
```
