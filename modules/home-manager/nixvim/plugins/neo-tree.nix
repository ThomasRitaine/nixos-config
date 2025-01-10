{
  plugins = {

    neo-tree = {
      enable = true;

      # Additional options to configure hidden files
      extraOptions.filesystem.filtered_items = {
        visible = true;          # Show hidden items but dimmed
        hide_dotfiles = false;
        hide_gitignored = true;
        hide_by_name = [ ".git" ]; # Explicitly hide `.git`
        never_show = [];         # Never explicitly hide other files
      };
    };

    web-devicons.enable = true;
  };
}
