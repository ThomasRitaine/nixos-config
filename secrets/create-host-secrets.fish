#!/usr/bin/env fish

function create-host-secrets
    set host $argv[1]

    if test -z "$host"
        echo "❌ Error: Please provide a hostname."
        return 1
    end

    # 1. Enter the secrets directory
    if test -d secrets
        cd secrets
    else if not test -f "secrets.nix"
        echo "❌ Error: Run this from your nixos-config root or secrets folder."
        return 1
    end

    set users thomas app-manager root

    echo "🚀 Creating secrets for: $host"
    echo -------------------------------------

    for user in $users
        set file "servers/$host/$user-password.age"

        # Ensure directory exists for the host
        mkdir -p (dirname "$file")

        echo "👤 User: $user"
        read -s -P "    Enter password: " pass_raw
        echo

        # 2. Hash password
        # Use printf to avoid echo interpretation issues and pass via stdin safely
        # -s tells mkpasswd to read from stdin
        set hash (printf "%s" "$pass_raw" | nix run nixpkgs#mkpasswd -- -m sha-512 -s)

        # 3. Write hash to a temp file
        set temp_secret (mktemp)
        # Using printf here as well to ensure no trailing newlines or escaped chars
        printf "%s" "$hash" >"$temp_secret"

        # 4. Use 'cp' as the editor
        # Ensure the .age file is actually created/updated
        env EDITOR="cp $temp_secret" agenix -e "$file"
        set agenix_status $status

        # Cleanup
        rm "$temp_secret"

        # 5. Verify success
        if test $agenix_status -eq 0 -a -f "$file"
            echo "   ✅ Saved to $file"
        else
            echo "   ❌ Error: Failed to create $file"
        end
        echo ""
    end

    # Return to original directory if we moved
    cd -
    echo "🎉 Done!"
end
