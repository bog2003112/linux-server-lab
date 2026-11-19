# SSH Basics

SSH provides encrypted remote access to Linux systems.

## Connect to a server

```bash
ssh USER@SERVER_ADDRESS
```

The first connection may ask you to verify the server host-key fingerprint. Confirm the fingerprint through a trusted channel before accepting it.

## Generate an SSH key pair

An Ed25519 key is a suitable default for most modern OpenSSH deployments:

```bash
ssh-keygen -t ed25519 -C "your-email-or-device-label"
```

The command creates a private key and a public key, usually under ~/.ssh/:

- id_ed25519 — private key. Keep it secret; never upload or send it.
- id_ed25519.pub — public key. This is the key that can be installed on a server or added to an account.

Protect the SSH directory and private key:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

## Install a public key on a Linux server

If password-based SSH access is enabled, ssh-copy-id can install the public key:

```bash
ssh-copy-id USER@SERVER_ADDRESS
```

Alternatively, append the contents of the .pub file to the remote user's ~/.ssh/authorized_keys file. Never copy the private key to the server.

## Test authentication

```bash
ssh -T USER@SERVER_ADDRESS
ssh -v USER@SERVER_ADDRESS
```

Use verbose mode to troubleshoot which key and authentication method the SSH client is using. Avoid sharing logs that contain private infrastructure details.

## GitHub SSH authentication

For GitHub, add the contents of the public key file (~/.ssh/id_ed25519.pub) under **Settings → SSH and GPG keys**. Then test:

```bash
ssh -T git@github.com
```

GitHub should identify the account if the matching public key is registered. GitHub does not provide interactive shell access; a successful authentication message is expected.

Never add ~/.ssh/id_ed25519 to GitHub. Only the .pub file is intended to be shared.
