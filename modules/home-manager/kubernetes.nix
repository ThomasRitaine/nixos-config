{lib, pkgs}: let
  my-kubernetes-helm = pkgs.wrapHelm pkgs.kubernetes-helm {
    plugins = with pkgs.kubernetes-helmPlugins; [
      helm-secrets
      helm-diff
      helm-s3
      helm-git
    ];
  };

  my-helmfile = pkgs.helmfile-wrapped.override {
    inherit (my-kubernetes-helm) pluginsDir;
  };
in {
  home.packages = [
    pkgs.kubectl
    my-kubernetes-helm
    my-helmfile
  ];

  programs.k9s.enable = true;
}
