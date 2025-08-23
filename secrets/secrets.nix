# Age encryption configuration
let
  # Replace these with your actual age keys
  # Generate with: age-keygen
  mabroor-personal = "age1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq"; # Replace with actual key
  mabroor-work = "age1rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr"; # Replace with actual key
  
  # System keys (generate with age-keygen for each host)
  amafcxnw09ryr = "age1ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss"; # Apple Silicon Mac
  mabroors-macbook-pro = "age1ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt"; # Intel Mac
  nixos-system = "age1uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu"; # NixOS system

  users = [ mabroor-personal mabroor-work ];
  systems = [ amafcxnw09ryr mabroors-macbook-pro nixos-system ];
  all = users ++ systems;
in
{
  # SSH private keys
  "ssh-key.age".publicKeys = all;
  
  # API tokens and credentials
  "github-token.age".publicKeys = all;
  "openai-api-key.age".publicKeys = all;
  "aws-credentials.age".publicKeys = all;
  
  # Database passwords
  "postgres-password.age".publicKeys = all;
  "redis-password.age".publicKeys = all;
  
  # Application secrets
  "jwt-secret.age".publicKeys = all;
  "encryption-key.age".publicKeys = all;
  
  # Email and notifications
  "smtp-password.age".publicKeys = all;
  "slack-webhook-url.age".publicKeys = all;
  
  # Host-specific secrets
  "wifi-password-home.age".publicKeys = [ mabroor-personal ] ++ systems;
  "wifi-password-work.age".publicKeys = [ mabroor-work ] ++ systems;
}