# ansible-linux-day0

Day 0 linux system config. Configures shell environment and installs useful cli tools and packages.

## Using

1. Install requirements:
```
python3, ansible >= 2.13"
```

```bash
ansible-galaxy install -r roles/requirements.yml
```

2. Run initial playbook to configure system:
```bash
ansible-playbook day0.yml -i inventory/k3s_nodes.yml -K
```

> Playbook assumes you already have an SSH public key on the system specified in the inventory file.

