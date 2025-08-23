# SSH configuration module
{ config, pkgs, lib, ... }:

{
  programs.ssh = {
    enable = true;
    
    # SSH client configuration
    compression = true;
    controlMaster = "auto";
    controlPath = "~/.ssh/control-%r@%h:%p";
    controlPersist = "10m";
    
    # Security settings
    hashKnownHosts = true;
    forwardAgent = false;
    
    
    # Host configurations
    matchBlocks = {
      # GitHub
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };

      # GitLab
      "gitlab.com" = {
        hostname = "gitlab.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };

      # Example work server
      "work-server" = {
        hostname = "server.work.example.com";
        user = "deploy";
        port = 22;
        identityFile = "~/.ssh/id_work";
        identitiesOnly = true;
        # Uncomment and configure as needed
        # proxyJump = "bastion.work.example.com";
        # localForwards = [
        #   {
        #     bind.port = 8080;
        #     host.address = "localhost";
        #     host.port = 3000;
        #   }
        # ];
      };

      # Example personal server
      "personal-server" = {
        hostname = "server.personal.example.com";
        user = "user";
        port = 2222;
        identityFile = "~/.ssh/id_personal";
        identitiesOnly = true;
      };

      # Development VMs pattern
      "dev-*" = {
        user = "developer";
        identityFile = "~/.ssh/id_dev";
        identitiesOnly = true;
        extraOptions = {
          "StrictHostKeyChecking" = "no";
          "UserKnownHostsFile" = "/dev/null";
          "LogLevel" = "ERROR";
        };
      };

      # Local development pattern
      "*.local" = {
        user = "admin";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
        extraOptions = {
          "StrictHostKeyChecking" = "no";
          "UserKnownHostsFile" = "/dev/null";
        };
      };

      # AWS EC2 instances pattern  
      "*.compute.amazonaws.com" = {
        user = "ec2-user";
        identityFile = "~/.ssh/aws-key.pem";
        identitiesOnly = true;
        extraOptions = {
          "StrictHostKeyChecking" = "no";
        };
      };

      # Default fallback for all hosts
      "*" = {
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
        extraOptions = {
          "VisualHostKey" = "yes";
          "VerifyHostKeyDNS" = "yes";
        };
      };
    };

    # Extra SSH configuration
    extraConfig = ''
      # Additional SSH client options
      Include ~/.ssh/config.local
      
      # SSH agent configuration
      AddKeysToAgent yes
      
      # Security enhancements
      Protocol 2
      Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
      MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-512
      KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256
      HostKeyAlgorithms ssh-ed25519-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256,ssh-rsa
      
      # Performance optimizations
      IPQoS throughput
      TCPKeepAlive yes
      
      ${lib.optionalString pkgs.stdenv.isDarwin ''
        # macOS-specific SSH agent configuration
        IgnoreUnknown UseKeychain
        UseKeychain yes
      ''}
    '';
  };

  # Create local SSH config file for additional customizations
  home.file.".ssh/config.local" = {
    text = ''
      # Local SSH configuration overrides
      # Add host-specific configurations here that shouldn't be in version control
      
      # Example:
      # Host my-private-server
      #   Hostname 192.168.1.100
      #   User myuser
      #   IdentityFile ~/.ssh/private-key
    '';
    # Don't recreate if it already exists to preserve local customizations
    force = false;
  };

  # SSH key management script
  home.file.".local/bin/ssh-key-setup" = {
    text = ''
      #!/usr/bin/env bash
      # SSH key setup script
      
      set -euo pipefail
      
      SSH_DIR="$HOME/.ssh"
      mkdir -p "$SSH_DIR"
      chmod 700 "$SSH_DIR"
      
      echo "🔑 SSH Key Setup Script"
      echo "======================"
      
      # Generate main ED25519 key if it doesn't exist
      if [ ! -f "$SSH_DIR/id_ed25519" ]; then
          echo "Generating main ED25519 SSH key..."
          ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f "$SSH_DIR/id_ed25519" -N ""
          echo "✅ Generated $SSH_DIR/id_ed25519"
      else
          echo "✅ Main ED25519 key already exists"
      fi
      
      # Generate work key if needed
      if [ ! -f "$SSH_DIR/id_work" ]; then
          read -p "Generate work SSH key? (y/N): " -n 1 -r
          echo
          if [[ $REPLY =~ ^[Yy]$ ]]; then
              ssh-keygen -t ed25519 -C "work-$(whoami)@$(hostname)" -f "$SSH_DIR/id_work" -N ""
              echo "✅ Generated $SSH_DIR/id_work"
          fi
      fi
      
      # Set correct permissions
      find "$SSH_DIR" -name "id_*" -type f ! -name "*.pub" -exec chmod 600 {} \;
      find "$SSH_DIR" -name "*.pub" -type f -exec chmod 644 {} \;
      
      echo
      echo "🔑 Your public keys:"
      echo "==================="
      for pub_key in "$SSH_DIR"/*.pub; do
          if [ -f "$pub_key" ]; then
              echo
              echo "$(basename "$pub_key"):"
              cat "$pub_key"
          fi
      done
      
      echo
      echo "📋 Next steps:"
      echo "=============="
      echo "1. Copy your public key(s) to clipboard"
      echo "2. Add them to your Git hosting service (GitHub, GitLab, etc.)"
      echo "3. Test SSH connection: ssh -T git@github.com"
      
      # macOS-specific keychain integration
      if [[ "$OSTYPE" == "darwin"* ]]; then
          echo "4. Keys will be added to keychain automatically on first use"
      fi
    '';
    executable = true;
  };
}