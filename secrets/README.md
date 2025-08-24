# Secrets Management with agenix

This directory contains encrypted secrets managed by [agenix](https://github.com/ryantm/agenix).

## Setup

1. **Generate age keys** for each user and system:

   ```bash
   # For personal use
   age-keygen -o ~/.config/age/keys.txt
   
   # For each system, generate a system key
   sudo age-keygen -o /etc/age/system-key.txt
   ```

2. **Update secrets.nix** with your actual public keys:
   - Replace the placeholder keys with your real age public keys
   - Add or remove keys as needed for your setup

3. **Create encrypted secrets**:

   ```bash
   # Install agenix
   nix profile install github:ryantm/agenix
   
   # Create a secret file
   agenix -e ssh-key.age
   
   # Edit existing secret
   agenix -e github-token.age
   
   # Re-key all secrets (after updating secrets.nix)
   agenix -r
   ```

## Usage in Configuration

### System-level secrets (NixOS):

```nix
{
  age.secrets.ssh-key = {
    file = ../secrets/ssh-key.age;
    owner = "root";
    group = "wheel";
    mode = "0600";
  };
}
```

### User-level secrets (home-manager):
```nix
{
  age.secrets.github-token = {
    file = ../secrets/github-token.age;
    owner = config.home.username;
    mode = "0600";
  };
}
```

## Available Secrets

- **ssh-key.age**: Private SSH keys
- **github-token.age**: GitHub personal access tokens
- **openai-api-key.age**: OpenAI API keys
- **aws-credentials.age**: AWS credentials
- **postgres-password.age**: PostgreSQL passwords
- **redis-password.age**: Redis passwords
- **jwt-secret.age**: JWT signing secrets
- **encryption-key.age**: Application encryption keys
- **smtp-password.age**: Email SMTP passwords
- **slack-webhook-url.age**: Slack webhook URLs
- **wifi-password-home.age**: Home WiFi password
- **wifi-password-work.age**: Work WiFi password

## Security Best Practices

1. **Never commit plaintext secrets** to the repository
2. **Use different keys** for different environments (dev/staging/prod)
3. **Rotate secrets regularly**
4. **Use principle of least privilege** - only give access to keys that need them
5. **Keep your age keys secure** and backed up safely
6. **Use system-specific secrets** when appropriate

## Troubleshooting

- **Permission denied**: Check that your age key is in the right location and has correct permissions
- **Cannot decrypt**: Ensure your public key is listed in secrets.nix for the secret you're trying to access
- **Re-keying issues**: Make sure all public keys in secrets.nix are valid age keys