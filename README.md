<div align="center">
    <h1>Ansible Linux Day 0</h1>
</div>

**ansible-linux-day0** is a server and workstation configuration repo designed 
to automatically install useful tools and applications. This is an
_opinionated_ set of choices based on my personal experience managing Linux 
systems.

## Getting Started

The playbook is designed to work on a baseline Ubuntu system. To get started, 
clone the repo to your system and run the `./bootstrap.sh` file. This script 
will install the latest version of ansible and the necessary ansible roles
defined in `roles/requirements.yml`.

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

## Ansible Roles

The following roles install a variety of packages and applications and apply 
configuration. The entry point for each role is the `main.yml` file which
includes a series of tasks via `ansible.builtin.include_tasks`. Each included
task has a corresponding variable which controls whether or not the tasks are
run.

Each role has a `defaults/main.yml` file which contains the `install_*`
variables. To skip run an included task, simply set the `install_*` variable
for the tasks you want to exclude to `false`.

### Common (`roles/common`)

#### Packages (`install_packages.yml`)

1. [btop](#btop)
2. [curl](#curl)
3. [fzf](#fzf)
4. [git](#git)
5. [net-tools](#net-tools)
6. [ripgrep](#ripgrep)
7. [unzip](#unzip)
8. [vim](#vim)
9. [wget](#wget)
10. [whois](#whois)
11. [zip](#zip)
12. [zoxide](#zoxide)

#### Tmux (`install_tmux.yml`)

tmux is a terminal multiplexer that allows users to manage multiple terminal sessions within a single window or session. With tmux, you can split a terminal into multiple panes, switch between them, and keep processes running in the background even if you disconnect from the session. It's especially useful for remote work, as you can disconnect from a session and reconnect later without losing any of the running processes.

#### Zsh (`install_zsh.yml`)

Zsh (Z shell) is an extended version of the Unix shell, with many improvements over the traditional Bash shell. It is widely used for interactive shell sessions due to its advanced features, ease of customization, and powerful scripting capabilities.

#### SSH Key (`install_ssh_key.yml`)

An ssh key is generated for the `ansible_user_id` with the type defined in the
`openssh_keypair_type` variable. The default type is set to **ed25519**.

#### NodeJS (`install_nodejs.yml`)

NodeJS is installed via the Node Version Manager (nvm). The NodeJS version to 
install is defined in the `nodejs_version` variable.

#### AWS CLI (`install_aws_cli.yml`)

The latest version of the AWS CLI v2 is downloaded from `awscli.amazonaws.com`
and is installed via the `./aws/install` command.

---

### Server Core (`roles/server_core`)

1. Unattended upgrades
2. Tmux `.tmux.conf`
3. Zsh `.zshrc`

---

### Workstation Core (`roles/workstation_core`)

1. [Dotfiles](#dotfiles)
2. [Libraries](#libraries)
3. [Luarocks](#luarocks)
4. [Neovim](#neovim)
5. [Python](#python)
6. [TypeScript](#typescript)
7. [FastFetch](#fastfetch)
8. [Docker](#docker)
9. [LazyDocker](#lazydocker)
10. [LazyGit](#lazygit)

---

### Workstation Desktop (`roles/workstation_desktop`)

1. [Alacritty](#alacritty)
2. [Flameshot](#flameshot)
3. [Regolith](#regolith)
4. [Chrome](#chrome)
5. [Microsoft Edge](#microsoft-edge)
6. [VSCode](#vscode)
7. [Ulauncher](#ulauncher)
8. [Remmina](#remmina)
