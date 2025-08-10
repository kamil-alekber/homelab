# Ansible Bootstrap for k0s Cluster Nodes

## What this does
1. Uses password auth (root/goodlife) for initial connection
2. Installs python (so Ansible can run modules), updates apt cache
3. Ensures openssh-server is installed
4. Copies your local `~/.ssh/id_rsa.pub` into `/root/.ssh/authorized_keys`
5. Adjusts sshd_config to disable password auth and ensure pubkey auth is enabled
6. Restarts SSH daemon

## Layout
- `ansible.cfg` - basic configuration
- `inventory/hosts.ini` - controller and worker groups
- `plays/bootstrap.yml` - entry playbook
- `roles/common` - tasks & handlers

## Run
```bash
ansible-playbook plays/bootstrap.yml
```

After confirming key based login works you can remove the password entries from `inventory/hosts.ini` or set `PasswordAuthentication no` (already done here).
