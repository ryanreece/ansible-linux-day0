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

Example:

```yaml
# vars.yml
# Don't install Regolith/i3
install_regolith: false
```

---

### Common

* Role file: [`roles/common/tasks/main.yml`](roles/common/tasks/main.yml)

The common role is used to install packages and configuration on both 
workstations and servers. 

#### Packages

* Task file: [`install_packages.yml`](roles/common/tasks/install_packages.yml)
* Install var: `install_packages: true`

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

#### Tmux

* Task file: [`install_tmux.yml`](roles/common/tasks/install_packages.yml)
* Install var: `install_tmux: true`

tmux is a terminal multiplexer that allows users to manage multiple terminal sessions within a single window or session. With tmux, you can split a terminal into multiple panes, switch between them, and keep processes running in the background even if you disconnect from the session. It's especially useful for remote work, as you can disconnect from a session and reconnect later without losing any of the running processes.

#### Zsh

* Task file: [`install_zsh.yml`](roles/common/tasks/install_zsh.yml)
* Install var: `install_zsh: true`

Zsh (Z shell) is an extended version of the Unix shell, with many improvements over the traditional Bash shell. It is widely used for interactive shell sessions due to its advanced features, ease of customization, and powerful scripting capabilities.

#### SSH Key

* Task file: [`install_ssh_key.yml`](roles/common/tasks/install_ssh_key.yml)
* Install var: `install_ssh_key: true`

An ssh key is generated for the `ansible_user_id` with the type defined in the
`openssh_keypair_type` variable. The default type is set to **ed25519**.

#### NodeJS

* Task file: [`install_nodejs.yml`](roles/common/tasks/install_nodejs.yml)
* Install var: `install_nodejs: true`

NodeJS is installed via the Node Version Manager (nvm). The NodeJS version to 
install is defined in the `nodejs_version` variable.

#### AWS CLI

* Task file: [`install_aws_cli.yml`](roles/common/tasks/install_aws_cli.yml)
* Install var: `install_aws_cli: true`

The latest version of the AWS CLI v2 is downloaded from `awscli.amazonaws.com`
and is installed via the `./aws/install` command.

---

### Server Core

* Role file: [`roles/server_core/tasks/main.yml`](roles/server_core/tasks/main.yml)

1. Unattended upgrades
2. Tmux `.tmux.conf`
3. Zsh `.zshrc`

---

### Workstation Core

* Role file: [`roles/workstation_core/tasks/main.yml`](roles/workstation_core/tasks/main.yml)

#### Dotfiles

* Task file: [`install_dotfiles.yml`](roles/workstation_core/tasks/install_dotfiles.yml)
* Install var: `install_dotfiles: true`

#### Libraries

* Task file: [`install_libraries.yml`](roles/workstation_core/tasks/install_libraries.yml)
* Install var: `install_libraries: true`

#### Luarocks

* Task file: [`install_luarocks.yml`](roles/workstation_core/tasks/install_luarocks.yml)
* Install var: `install_luarocks: true`

#### Neovim

* Task file: [`install_neovim.yml`](roles/workstation_core/tasks/install_neovim.yml)
* Install var: `install_neovim: true`

#### Python

* Task file: [`install_python.yml`](roles/workstation_core/tasks/install_python.yml)
* Install var: `install_python: true`

#### TypeScript

* Task file: [`install_typescript.yml`](roles/workstation_core/tasks/install_typescript.yml)
* Install var: `install_typescript: true`

#### FastFetch

* Task file: [`install_fastfetch.yml`](roles/workstation_core/tasks/install_fastfetch.yml)
* Install var: `install_fastfetch: true`

#### Docker

* Task file: [`install_docker.yml`](roles/workstation_core/tasks/install_docker.yml)
* Install var: `install_docker: true`

#### LazyDocker

* Task file: [`install_lazydocker.yml`](roles/workstation_core/tasks/install_lazydocker.yml)
* Install var: `install_lazydocker: true`

#### LazyGit

* Task file: [`install_lazygit.yml`](roles/workstation_core/tasks/install_lazygit.yml)
* Install var: `install_lazygit: true`

#### Minicom

* Task file: [`install_minicom.yml`](roles/workstation_core/tasks/install_minicom.yml)
* Install var: `install_minicom: true`

---

### Workstation Desktop

* Role file: [`roles/workstation_desktop/tasks/main.yml`](roles/workstation_desktop/tasks/main.yml)

#### Alacritty

* Task file: [`install_alacritty.yml`](roles/workstation_desktop/tasks/install_alacritty.yml)
* Install var: `install_alacritty: true`

#### Flameshot

* Task file: [`install_flameshot.yml`](roles/workstation_desktop/tasks/install_flameshot.yml)
* Install var: `install_flameshot: true`

#### Regolith

* Task file: [`install_regolith.yml`](roles/workstation_desktop/tasks/install_regolith.yml)
* Install var: `install_regolith: true`

#### Chrome

* Task file: [`install_chrome.yml`](roles/workstation_desktop/tasks/install_chrome.yml)
* Install var: `install_chrome: true`

#### Microsoft Edge 

* Task file: [`install_microsoft_edge.yml`](roles/workstation_desktop/tasks/install_microsoft_edge.yml)
* Install var: `install_microsoft_edge: true`

#### VSCode

* Task file: [`install_vscode.yml`](roles/workstation_desktop/tasks/install_vscode.yml)
* Install var: `install_vscode: true`

#### Ulauncher

* Task file: [`install_ulauncher.yml`](roles/workstation_desktop/tasks/install_ulauncher.yml)
* Install var: `install_ulauncher: true`

#### Remmina

* Task file: [`install_remmina.yml`](roles/workstation_desktop/tasks/install_remmina.yml)
* Install var: `install_remmina: true`

#### KeePassXC

* Task file: [`install_keepassxc.yml`](roles/workstation_desktop/tasks/install_keepassxc.yml)
* Install var: `install_keepassxc: true`
