{ lib, ... }: {
  programs.starship.enable = true;

  programs.starship.settings = {
    # Color gradient used : https://huemint.com/gradient-7/#palette=a3aed2-769ff0-3883c5-3c699a-31486e-2a3e4f-1d2230
    # From the brighter to the darker : #a3aed2, #769ff0, #3883c5, #3c699a, #31486e, #2a3e4f, #1d2230

    # Font color for each block : https://huemint.com/gradient-7/#palette=1a1a1a-e1eaf8-f0e68c-e9f2ff-e1eaf8-dde6f4-c8d2e7
    # From the left hand block to the right one : #1a1a1a, #e1eaf8, #f0e68c, #e9f2ff, #e1eaf8, #dde6f4, #c8d2e7

    format = lib.concatStrings [
      "[╭─◀](#a3aed2)"
      "[ \${env_var.DISTRO_ICON} ](fg:#000000 bg:#a3aed2)"
      "[](fg:#a3aed2 bg:#769ff0)"
      "$username\${custom.user_emoji}"
      "\${custom.local_hostname}"
      "$hostname"
      "[](fg:#769ff0 bg:#3883c5)"
      "$directory"
      "[](fg:#3883c5 bg:#3c699a)"
      "$git_branch"
      "\${custom.giturl}"
      "$git_status"
      "[](fg:#3c699a bg:#31486e)"
      "\${custom.docker}"
      "[](fg:#31486e bg:#2a3e4f)"
      "$nodejs"
      "$php"
      "$python"
      "[](fg:#2a3e4f bg:#1d2230)"
      "$time"
      "[ ](fg:#1d2230)"
      "$fill"
      "$status"
      "$cmd_duration"
      "( 🥵$memory_usage)"
      "$line_break"
      "[╰─](#a3aed2)"
      "[❯ ](#a3aed2)"
    ];

    command_timeout = 1500;

    # Shows an icon depending on what distro it is running on
    env_var = {
      DISTRO_ICON = {
        format = "$env_value";
        variable = "DISTRO_ICON";
      };
    };

    custom = {
      user_emoji = {
        command = ''
          if [ "$USER" = "thomas" ]; then
            echo "🐣"
          elif [ "$USER" = "root" ]; then
            echo "👑"
          fi
        '';
        format = "[( $output )]($style)";
        style = "bg:#769ff0";
        when = true;
      };

      local_hostname = {
        command = ''[ -z "$SSH_CONNECTION" ] && echo "in "'';
        format = "[( $output )]($style)";
        style = "fg:#e1eaf8 bg:#769ff0";
        when = true;
      };

      docker = {
        command = ''
               docker compose $(ls docker-compose*.yml | sed "s/^/-f /") ps -a --format json \
                 | jq -s -r "if . == [] then \"uncreated\" \
                   elif .[0] | type == \"array\" then .[0][0].State? // \"uncreated\" \
                   else .[0].State? // \"uncreated\" \
          end"
        '';
        detect_files = [ "docker-compose.yml" ];
        format = "[ $symbol ($output )]($style)";
        style = "fg:#0db7ed bg:#31486e";
        symbol = " ";
      };

      giturl = {
        command = ''
          GIT_REMOTE=$(command git ls-remote --get-url 2> /dev/null)
          if [[ "$GIT_REMOTE" =~ "github" ]]; then
            GIT_REMOTE_SYMBOL=" "
          elif [[ "$GIT_REMOTE" =~ "gitlab" ]]; then
            GIT_REMOTE_SYMBOL=" "
          elif [[ "$GIT_REMOTE" =~ "bitbucket" ]]; then
            GIT_REMOTE_SYMBOL=" "
          else
            GIT_REMOTE_SYMBOL=" "
          fi
          echo "$GIT_REMOTE_SYMBOL "
        '';
        description = "Display symbol for remote Git server";
        format = "[on $output  ]($style)";
        style = "fg:#e9f2ff bg:#3c699a";
        when = "git rev-parse --is-inside-work-tree 2> /dev/null";
      };
    };

    username = {
      format = "[ $user]($style)";
      show_always = true;
      style_root = "fg:#e1eaf8 bg:#769ff0";
      style_user = "fg:#e1eaf8 bg:#769ff0";
    };

    hostname = {
      format = "[ in $hostname]($style)";
      ssh_only = true;
      ssh_symbol = "";
      style = "fg:#e1eaf8 bg:#769ff0";
      trim_at = "";
    };

    directory = {
      format = "[ $path ($read_only )]($style)";
      read_only = "";
      style = "fg:#f0e68c bg:#3883c5";
      truncate_to_repo = false;
      truncation_length = 5;
      truncation_symbol = "…/";
    };

    git_branch = {
      format = "[ $symbol$branch ]($style)";
      style = "fg:#e9f2ff bg:#3c699a";
      symbol = " ";
    };

    git_status = {
      format = "([\\[$all_status$ahead_behind\\]]($style))";
      style = "fg:#e9f2ff bg:#3c699a";
    };

    nodejs = {
      format = "[ on $symbol]($style)";
      style = "fg:#6cc24a bg:#2a3e4f";
      symbol = " ";
    };

    php = {
      format = "[ on [$symbol]($style)]($style)";
      style = "fg:#99cc99 bg:#2a3e4f";
      symbol = " ";
    };

    python = {
      format = "[ on $symbol]($style)";
      style = "fg:#4584b6 bg:#2a3e4f";
      symbol = " ";
    };

    time = {
      disabled = false;
      format = "[  $time ]($style)";
      style = "fg:#c8d2e7 bg:#1d2230";
      time_format = "%R"; # Hour:Minute Format
    };

    fill = { symbol = " "; };

    status = { disabled = false; };

    cmd_duration = {
      format = "⌛$duration";
      min_time = 1000; # Show command duration over 1,000 milliseconds
      show_milliseconds = true;
    };

    memory_usage = {
      disabled = false;
      format = " $symbol[$ram]($style)";
      symbol = "󰍛 ";
      threshold = 66;
    };
  };
}
