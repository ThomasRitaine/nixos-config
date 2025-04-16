{ pkgs, ... }: {
  home.packages = [
    (pkgs.writeShellScriptBin "kp" ''
      #!/usr/bin/env bash

      # Simple header focusing on TAB, ENTER and ESC
      HEADER="[Kill Process] Use TAB to select multiple processes, ENTER to kill, ESC to cancel"

      # Column header for process list
      COLUMN_HEADER="  PID       USER          CPU%   MEM%   COMMAND"

      # Get process list with formatting
      process_list=$(${pkgs.procps}/bin/ps -e -o pid,user,pcpu,pmem,comm --sort=-%cpu | 
                      tail -n +2 |
                      awk '{printf "%-10s %-12s %-6.1f %-6.1f %s\n", $1, $2, $3, $4, $5}')

      # Run fzf with multi-select enabled
      selected=$(echo "$process_list" | 
                ${pkgs.fzf}/bin/fzf \
                  --header="$HEADER"$'\n'"$COLUMN_HEADER" \
                  --layout=reverse \
                  --multi \
                  --prompt="Search: ")

      # Exit if nothing was selected
      if [ -z "$selected" ]; then
        exit 0
      fi

      # Extract PIDs from selection
      PIDs=$(echo "$selected" | awk '{print $1}')

      # Make sure we have PIDs
      if [ -z "$PIDs" ]; then
        echo "No process selected."
        exit 0
      fi

      # Show what will be killed
      echo -e "\nProcess(es) to terminate:"
      ${pkgs.procps}/bin/ps -f -p $PIDs

      # Simple confirmation that accepts "y" or "yes"
      read -p "Kill these processes? [y/N] " confirm

      if [[ "$confirm" =~ ^[Yy][Ee]?[Ss]?$ ]]; then
        # Kill each process individually to handle errors gracefully
        for pid in $PIDs; do
          # Check if process needs elevated privileges
          if ! kill -0 $pid 2>/dev/null; then
            echo "Process $pid requires elevated privileges."
            sudo kill $pid
          else
            kill $pid
          fi
        done
        
        echo "Process(es) terminated."
      else
        echo "Operation cancelled."
      fi
    '')

    # Dependencies
    pkgs.procps
    pkgs.fzf
  ];
}
