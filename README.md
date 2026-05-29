<div align="center">

# Ansible Linux Day 0

Opinionated Ansible automation for bootstrapping Linux workstations and servers.

![Ansible](https://img.shields.io/badge/Ansible-linux%20automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-workstation%20bootstrap-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Platforms](https://img.shields.io/badge/Platforms-Ubuntu%20%7C%20RHEL%20%7C%20Arch-2E3440?style=for-the-badge)

</div>

`ansible-linux-day0` is a personal day-zero configuration repo for getting a
fresh Linux machine into a useful working state. It installs common terminal
tools, developer runtimes, shells, workstation applications, desktop utilities,
and a small amount of user configuration.

The playbooks are intentionally opinionated, but each feature is controlled by
an `install_*` variable so the default workstation can be trimmed down per host
or inventory.

## Contents

- [Supported Platforms](#supported-platforms)
- [Omarchy Notes](#omarchy-notes)
- [Quick Start](#quick-start)
- [Playbooks](#playbooks)
- [Feature Toggles](#feature-toggles)
- [Roles](#roles)
- [Validation](#validation)
- [Repository Layout](#repository-layout)
- [Cross-Distro Development](#cross-distro-development)

## Supported Platforms

Support is being expanded from Ubuntu-first coverage toward a broader
cross-distro workstation bootstrap.

| Platform | Bootstrap | Workstation | Server | Notes |
| --- | --- | --- | --- | --- |
| Ubuntu | Supported | Best supported | Supported | Primary historical target. Regolith is Ubuntu-only. |
| Debian family | Partial | Partial | Partial | Many tasks work, but Ubuntu-only PPAs/repos are guarded or still being refined. |
| RHEL | Supported | Partial | Partial | Uses RPM/DNF paths where available. |
| Rocky / AlmaLinux | Partial | Partial | Partial | Expected to follow RedHat-family paths; test per feature. |
| Fedora | Not in bootstrap yet | Partial | Not verified | Many RedHat-family package tasks should work, but bootstrap coverage is not complete. |
| Arch Linux | Supported | Partial | Not verified | The tested Arch target is Omarchy, not a generic hand-rolled Arch install. |
| [Omarchy](https://omarchy.org/) / Hyprland on Arch | N/A | Active support | N/A | Tested against the Omarchy spin by DHH. Install Omarchy first, then run this playbook to tune it. |

Desktop-environment assumptions are intentionally conservative:

- KDE Plasma is opt-in only with `install_kde: true`.
- Regolith is only attempted on Ubuntu.
- AUR-only applications are limited to explicit app tasks such as Chrome and
  Microsoft Edge on Arch.

## Omarchy Notes

[Omarchy](https://omarchy.org/) describes itself as "Beautiful, Modern &
Opinionated Linux by DHH" and links its manual, ISO, and GitHub project from
the main site. The Arch workflow in this repository assumes that Omarchy has
already been installed on the machine.

Recommended flow:

1. Follow the Omarchy website and manual to install Omarchy onto a fresh
   computer.
2. Boot into the completed Omarchy system.
3. Clone this repository.
4. Run `./bootstrap.sh`.
5. Run the workstation playbook.

This playbook is intended to layer personal day-zero workstation preferences on
top of Omarchy. It deliberately supersedes some Omarchy opinions, including
installing this repo's Neovim configuration and tmux bindings. Tasks that
replace preexisting user configuration should preserve the original directory or
file with a backup before installing the playbook-managed version.

Current Omarchy/Hyprland-specific behavior includes:

- Tuning `~/.config/hypr/looknfeel.conf` when Hyprland is installed and the
  file exists.
- Enabling the Omarchy screenshot binding in
  `~/.config/hypr/bindings.conf` when the commented binding exists.
- Backing up unmanaged `~/.config/nvim` before installing the playbook-managed
  Neovim config.

## Quick Start

Clone the repository on the target host, install Ansible and role dependencies,
then run the workstation playbook locally.

For Omarchy systems, install Omarchy first from the official Omarchy project,
then run this repo on top of that completed install.

```bash
./bootstrap.sh
./install-workstation.sh
```

`install-workstation.sh` runs:

```bash
ansible-playbook -i localhost, day0-workstation.yml --connection=local -K
```

The wrapper prompts for the sudo password and reboots after completion. Run the
raw `ansible-playbook` command directly if you want more control over tags,
check mode, or reboot timing.

## Playbooks

### Workstation

```bash
ansible-playbook -i localhost, day0-workstation.yml --connection=local -K
```

The workstation playbook applies:

- `common`
- `workstation_core`
- `workstation_desktop`

Run a single feature by tag:

```bash
ansible-playbook -i localhost, day0-workstation.yml --connection=local -K --tags docker
```

### Server

Server targets should be listed under `inventory/`.

```bash
ansible-playbook -i inventory/server.yml day0-server.yml -K
```

The server playbook applies:

- `common`
- `server_core`

## Feature Toggles

Each role exposes defaults in `defaults/main.yml`. Set an `install_*` variable
to `false` to skip a feature.

Example:

```yaml
install_regolith: false
install_kde: false
install_chrome: false
```

Feature variables can be set in inventory, host vars, group vars, or an extra
vars file:

```bash
ansible-playbook -i localhost, day0-workstation.yml \
  --connection=local \
  -K \
  -e @vars.yml
```

## Roles

### Common

Role entry point: [`roles/common/tasks/main.yml`](roles/common/tasks/main.yml)

Shared server and workstation setup.

| Feature | Task file | Toggle |
| --- | --- | --- |
| Baseline packages | [`install_packages.yml`](roles/common/tasks/install_packages.yml) | `install_packages` |
| tmux | [`install_tmux.yml`](roles/common/tasks/install_tmux.yml) | `install_tmux` |
| zsh | [`install_zsh.yml`](roles/common/tasks/install_zsh.yml) | `install_zsh` |
| SSH key | [`install_ssh_key.yml`](roles/common/tasks/install_ssh_key.yml) | `install_ssh_key` |
| NodeJS via nvm | [`install_nodejs.yml`](roles/common/tasks/install_nodejs.yml) | `install_nodejs` |
| AWS CLI | [`install_aws_cli.yml`](roles/common/tasks/install_aws_cli.yml) | `install_aws_cli` |

### Server Core

Role entry point: [`roles/server_core/tasks/main.yml`](roles/server_core/tasks/main.yml)

Server-only configuration.

| Feature | Notes |
| --- | --- |
| Hostname | Sets hostname from inventory name. |
| Package upgrades | Debian-family upgrade task. |
| Unattended upgrades | Configured through the role dependency in `meta/main.yml`. |
| tmux/zsh config | Deploys role templates for server sessions. |

### Workstation Core

Role entry point: [`roles/workstation_core/tasks/main.yml`](roles/workstation_core/tasks/main.yml)

Developer tooling and CLI applications.

| Feature | Task file | Toggle |
| --- | --- | --- |
| Dotfiles | [`install_dotfiles.yml`](roles/workstation_core/tasks/install_dotfiles.yml) | `install_dotfiles` |
| Build libraries | [`install_libraries.yml`](roles/workstation_core/tasks/install_libraries.yml) | `install_libraries` |
| Python | [`install_python.yml`](roles/workstation_core/tasks/install_python.yml) | `install_python` |
| Go | [`install_go.yml`](roles/workstation_core/tasks/install_go.yml) | `install_go` |
| TypeScript | [`install_typescript.yml`](roles/workstation_core/tasks/install_typescript.yml) | `install_typescript` |
| Ruby | [`install_ruby.yml`](roles/workstation_core/tasks/install_ruby.yml) | `install_ruby` |
| LuaRocks | [`install_luarocks.yml`](roles/workstation_core/tasks/install_luarocks.yml) | `install_luarocks` |
| Neovim | [`install_neovim.yml`](roles/workstation_core/tasks/install_neovim.yml) | `install_neovim` |
| Fastfetch | [`install_fastfetch.yml`](roles/workstation_core/tasks/install_fastfetch.yml) | `install_fastfetch` |
| Docker | [`install_docker.yml`](roles/workstation_core/tasks/install_docker.yml) | `install_docker` |
| Cloud utilities | [`install_cloud_utilities.yml`](roles/workstation_core/tasks/install_cloud_utilities.yml) | `install_cloud_utilities` |
| Cisco Secure Client | [`install_cisco_secure_client.yml`](roles/workstation_core/tasks/install_cisco_secure_client.yml) | `install_cisco_secure_client` |
| ProxyChains-NG | [`install_proxychains_ng.yml`](roles/workstation_core/tasks/install_proxychains_ng.yml) | `install_proxychains_ng` |
| LazyDocker | [`install_lazydocker.yml`](roles/workstation_core/tasks/install_lazydocker.yml) | `install_lazydocker` |
| LazyGit | [`install_lazygit.yml`](roles/workstation_core/tasks/install_lazygit.yml) | `install_lazygit` |
| Minicom | [`install_minicom.yml`](roles/workstation_core/tasks/install_minicom.yml) | `install_minicom` |
| Terraform | [`install_terraform.yml`](roles/workstation_core/tasks/install_terraform.yml) | `install_terraform` |
| PowerShell | [`install_powershell.yml`](roles/workstation_core/tasks/install_powershell.yml) | `install_powershell` |

### Workstation Desktop

Role entry point: [`roles/workstation_desktop/tasks/main.yml`](roles/workstation_desktop/tasks/main.yml)

GUI applications and desktop-specific behavior.

| Feature | Task file | Toggle |
| --- | --- | --- |
| Alacritty | [`install_alacritty.yml`](roles/workstation_desktop/tasks/install_alacritty.yml) | `install_alacritty` |
| Flameshot | [`install_flameshot.yml`](roles/workstation_desktop/tasks/install_flameshot.yml) | `install_flameshot` |
| Hyprland settings | [`install_hyprland_settings.yml`](roles/workstation_desktop/tasks/install_hyprland_settings.yml) | `install_hyprland_settings` |
| Regolith | [`install_regolith.yml`](roles/workstation_desktop/tasks/install_regolith.yml) | `install_regolith` |
| KDE Plasma | [`install_kde.yml`](roles/workstation_desktop/tasks/install_kde.yml) | `install_kde` |
| Chrome | [`install_chrome.yml`](roles/workstation_desktop/tasks/install_chrome.yml) | `install_chrome` |
| Microsoft Edge | [`install_microsoft_edge.yml`](roles/workstation_desktop/tasks/install_microsoft_edge.yml) | `install_microsoft_edge` |
| VSCode / Code - OSS | [`install_vscode.yml`](roles/workstation_desktop/tasks/install_vscode.yml) | `install_vscode` |
| Ulauncher | [`install_ulauncher.yml`](roles/workstation_desktop/tasks/install_ulauncher.yml) | `install_ulauncher` |
| Remmina | [`install_remmina.yml`](roles/workstation_desktop/tasks/install_remmina.yml) | `install_remmina` |
| KeePassXC | [`install_keepassxc.yml`](roles/workstation_desktop/tasks/install_keepassxc.yml) | `install_keepassxc` |

## Validation

Run syntax checks before applying changes:

```bash
ansible-playbook -i localhost, day0-workstation.yml --connection=local --syntax-check
ansible-playbook -i localhost, day0-server.yml --connection=local --syntax-check
```

Run a feature in check mode with tags:

```bash
ansible-playbook -i localhost, day0-workstation.yml \
  --connection=local \
  --check \
  --tags go
```

If available, run:

```bash
ansible-lint
```

## Repository Layout

```text
.
├── ansible.cfg
├── bootstrap.sh
├── day0-server.yml
├── day0-workstation.yml
├── install-workstation.sh
├── inventory/
└── roles/
    ├── common/
    ├── server_core/
    ├── workstation_core/
    └── workstation_desktop/
```

## Cross-Distro Development

When adding features, follow the existing role structure:

1. Add an `install_<feature>` default in the role's `defaults/main.yml`.
2. Add an `include_tasks` entry in the role's `tasks/main.yml`.
3. Put implementation in `tasks/install_<feature>.yml`.
4. Add a tag matching the feature name.
5. Use `ansible_facts['os_family']` for broad package-manager paths.
6. Use `ansible_distribution` only for distro-specific repositories or apps.

Prefer `ansible.builtin.package` when package names are shared across distros.
Use package-manager-specific modules only when necessary.

Important platform notes:

- Ubuntu-only PPAs or repositories must be guarded with
  `ansible_distribution == 'Ubuntu'`.
- RedHat-family work should use DNF/RPM paths where needed.
- Arch work should be tested against Omarchy unless a task explicitly targets
  generic Arch. Prefer official pacman packages where possible.
- AUR support is limited to specific application tasks that need it.
- Desktop environment installs should be opt-in unless they are lightweight app
  installs.

For more detailed agent guidance, see [`AGENTS.md`](AGENTS.md).
