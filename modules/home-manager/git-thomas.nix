{ email ? "thomas.ritaine@example.com" }: {
  programs.git = {
    enable = true;
    userName = "Thomas Ritaine";
    userEmail = "${email}";
    extraConfig.init.defaultBranch = "main";
  };
}
