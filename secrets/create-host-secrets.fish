#!/usr/bin/env fish

function create-host-secrets
    set host $argv[1]

    if test -z "$host"
        echo "Error: Please provide a hostname."
        return 1
    end

    if test -d secrets
        cd secrets
    else if not test -f "secrets.nix"
        echo "Error: Run this from your nixos-config root or secrets folder."
        return 1
    end

    set users thomas root

    echo "Creating secrets for: $host"
    echo -------------------------------------

    for user in $users
        set file "servers/$host/$user-password.age"
        mkdir -p (dirname "$file")

        echo "User: $user"
        read -s -P "    Enter password: " pass_raw
        echo

        set hash (printf "%s" "$pass_raw" | nix run nixpkgs#mkpasswd -- -m sha-512 -s)

        set temp_secret (mktemp)
        printf "%s" "$hash" >"$temp_secret"

        env EDITOR="cp $temp_secret" agenix -e "$file"
        set agenix_status $status

        rm "$temp_secret"

        if test $agenix_status -eq 0 -a -f "$file"
            echo "   Saved to $file"
        else
            echo "   Error: Failed to create $file"
        end
        echo ""
    end

    set restic_file "servers/$host/restic-password.age"
    echo "Service: restic"
    read -s -P "    Enter restic password: " restic_pass_raw
    echo

    set restic_temp (mktemp)
    printf "%s" "$restic_pass_raw" >"$restic_temp"

    env EDITOR="cp $restic_temp" agenix -e "$restic_file"
    set agenix_restic_status $status

    rm "$restic_temp"

    if test $agenix_restic_status -eq 0 -a -f "$restic_file"
        echo "   Saved to $restic_file"
    else
        echo "   Error: Failed to create $restic_file"
    end
    echo ""

    cd -
    echo "Done."
end
