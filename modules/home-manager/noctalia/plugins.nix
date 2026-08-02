{ pkgs, ... }:
{
  programs.noctalia-shell = {
    enable = true;
    plugins = {
      sources = [
        {
          enabled = true;
          name = "Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];
      states = {
        privacy-indicator = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        screen-toolkit = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
      };
      version = 2;
    };
  };

  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    tesseract
    imagemagick
    zbar
    curl
    wl-screenrec
    ffmpeg
    gifski
    jq
  ];
}
