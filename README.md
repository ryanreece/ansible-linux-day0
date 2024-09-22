<div align="center">
    <h1>ansible-linux-day0</h1>
</div>
<hr>

ansible-linux-day0 is a server and workstation configuration repo designed to
automatically install useful tools and applications. This is an _opinionated_ 
set of choices based on my personal experience managing Unix-based systems. 

## Getting Started

The playbook is designed to work on a baseline Ubuntu system. To get started, 
clone the repo to your system and run the `./bootstrap.sh` file. This script 
will install the core requirement of the latest version of ansible as well as 
install the necessary ansible roles in `roles/requirements.yml`.

1. Run `bootstrap.sh`:

```bash
./bootstrap.sh
```

2. Run `install-workstation.sh` to configure the current workstation:

```bash
./install-workstation.sh
```

### Configuring Servers

The playbook assumes you have a list of target servers defined in the 
`inventory/` directory.

1. Run `ansible-playbook`:

```bash
ansible-playbook -i inventory/server.yml day0-server.yml -K
```

## Packages & Applications

### Common

1. Packages
2. Tmux
3. Zsh
4. SSH Key
5. NodeJS
6. AWS CLI

### Server Core

1. Unattended upgrades
2. Tmux `.tmux.conf`
3. Zsh `.zshrc`

### Workstation Core

1. Dotfiles
2. Libraries
3. Luarocks
4. Neovim
5. Python
6. TypeScript
7. FastFetch
8. Docker
9. LazyDocker
10. LazyGit

### Workstation Desktop

1. Alacritty
2. Flameshot
3. Regolith
4. Chrome
5. Ulauncher
