{ email ? "thomas.ritaine@example.com", sshSigningKey ? null, }: {
  programs.git = {
    enable = true;
    userName = "Thomas Ritaine";
    userEmail = "${email}";
    signing = {
      key = sshSigningKey;
      format = "ssh";
      signByDefault = true;
    };
    extraConfig = { init.defaultBranch = "main"; };
  };
}
