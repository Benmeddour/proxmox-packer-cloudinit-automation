# SSH Keys Directory

This directory is for storing SSH keys used during the Packer build process.

## Usage

1. **Generate SSH Key Pair** (if you don't have one):

   ```powershell
   ssh-keygen -t rsa -b 4096 -f ssh/id_rsa -N ""
   ```

2. **Use SSH Key in Template**:
   Update your .env file or variables to use key authentication:

   ```bash
   # In .env file
   SSH_PRIVATE_KEY_FILE=./ssh/id_rsa
   ```

3. **Update user-data**:
   Replace the SSH key in `http/user-data` with your public key:
   ```yaml
   ssh_authorized_keys:
     - ssh-rsa AAAAB3NzaC1yc2E... your-key-here
   ```

## Security Notes

- SSH keys in this directory are automatically ignored by git
- Never commit private keys to version control
- Use different keys for different environments
- Consider using SSH agent for better security

## Files

- `id_rsa` - Private key (auto-ignored by git)
- `id_rsa.pub` - Public key (safe to share)
- `example.pub` - Example public key format
