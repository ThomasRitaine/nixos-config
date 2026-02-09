{
  email ? "thomas.ritaine@example.com",
  sshSigningKey ? null,
}:
{
  programs.git = {
    enable = true;

    signing = {
      key = sshSigningKey;
      format = "ssh";
      signByDefault = true;
    };

    settings = {
      user = {
        name = "Thomas Ritaine";
        email = "${email}";
      };

      init = {
        defaultBranch = "main";
      };
    };
  };
}
