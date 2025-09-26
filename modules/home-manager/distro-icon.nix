{ pkgs, ... }:
let
  script = ''
    AWK=${pkgs.gawk}/bin/awk

    # find out which distribution we are running on
    if [[ $(find /etc -maxdepth 1 -type f -name "*-release" | wc -l) -gt 0 ]]; then
      _distro=$($AWK '/^ID=/' /etc/*-release | $AWK -F'=' '{ print tolower($2) }')
    elif [[ -f "/System/Library/CoreServices/SystemVersion.plist" ]]; then
      _distro="macos"
    elif [[ -f "/etc/os-release" ]]; then
      _distro=$($AWK '/^ID=/' /etc/os-release | $AWK -F'=' '{ print tolower($2) }')
    fi

    case $_distro in
        *kali*)                  ICON="ﴣ";;
        *arch*)                  ICON="";;
        *debian*)                ICON="";;
        *raspbian*)              ICON="";;
        *ubuntu*)                ICON="";;
        *elementary*)            ICON="";;
        *fedora*)                ICON="";;
        *coreos*)                ICON="";;
        *gentoo*)                ICON="";;
        *mageia*)                ICON="";;
        *centos*)                ICON="";;
        *opensuse*|*tumbleweed*) ICON="";;
        *sabayon*)               ICON="";;
        *slackware*)             ICON="";;
        *linuxmint*)             ICON="";;
        *alpine*)                ICON="";;
        *aosc*)                  ICON="";;
        *nixos*)                 ICON="";;
        *devuan*)                ICON="";;
        *manjaro*)               ICON="";;
        *rhel*)                  ICON="";;
        *macos*)                 ICON="";;
        *)                       ICON="";;
    esac

    # Export variables
    export DISTRO="$_distro"
    export DISTRO_ICON="$ICON"
  '';
in {
  programs.zsh.initContent = ''
    ${script}
  '';
}
