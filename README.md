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
| Fedora Sway Spin | Supported | Partial | Not verified | Common packages use DNF-compatible paths, and the desktop role supports Sway utilities plus Fedora RPM application paths; broader workstation-core coverage is still being refined. |
| Arch Linux | Supported | Partial | Not verified | The tested Arch target is Omarchy, not a generic hand-rolled Arch install. |
| [Omarchy](https://omarchy.org/) / Hyprland on Arch | N/A | Active support | N/A | Tested against the Omarchy spin by DHH. Install Omarchy first, then run this playbook to tune it. |

Desktop-environment assumptions are intentionally conservative:

- KDE Plasma is opt-in only with `install_kde: true`.
- Regolith is only attempted on Ubuntu.
- Fedora Sway Spin detects the Sway installation provided by the spin and
  installs missing Sway-native supporting utilities. User settings (terminal,
  keybindings, and monitor scaling) are managed by the dotfiles repository via
  `install_dotfiles.sh`, not by the Sway tasks. The playbook does not install
  or replace the Sway session itself.
- Fedora bootstrap support targets the standard DNF-based Sway Spin; immutable
  Fedora Atomic variants require an rpm-ostree-specific workflow.
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

For a one-off host that should not be saved in the repository, pass an inline
inventory. The trailing comma tells Ansible that the value is a host list:

```bash
ansible-playbook -i 'server01.lab.int.reece.ai,' day0-server.yml -K
```

On hosts where sudo-rs provides the default `sudo` command, select Ubuntu's
traditional sudo executable for that run with `ansible_become_exe`:

```bash
ansible-playbook \
  -i 'server01.lab.int.reece.ai,' \
  day0-server.yml \
  -K \
  -e ansible_become_exe=/usr/bin/sudo.ws
```

This override applies only to the current invocation and does not change
`ansible.cfg` or require a committed inventory file. If the setting needs to be
reused, place it in an external variables file and pass that file with
`-e @/path/to/server01.yml`.

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
| Flatpak / Flathub (Fedora) | [`install_flatpak.yml`](roles/common/tasks/install_flatpak.yml) | `install_flatpak` |
| tmux | [`install_tmux.yml`](roles/common/tasks/install_tmux.yml) | `install_tmux` |
| zsh | [`install_zsh.yml`](roles/common/tasks/install_zsh.yml) | `install_zsh` |
| SSH key | [`install_ssh_key.yml`](roles/common/tasks/install_ssh_key.yml) | `install_ssh_key` |
| NodeJS via nvm | [`install_nodejs.yml`](roles/common/tasks/install_nodejs.yml) | `install_nodejs` |
| AWS CLI | [`install_aws_cli.yml`](roles/common/tasks/install_aws_cli.yml) | `install_aws_cli` |

### Server Core

Role entry point: [`roles/server_core/tasks/main.yml`](roles/server_core/tasks/main.yml)

Server-only configuration.

| Feature | Task file | Toggle | Notes |
| --- | --- | --- | --- |
| Hostname | [`set_hostname.yml`](roles/server_core/tasks/set_hostname.yml) | `install_server_hostname` | Sets hostname from inventory name. |
| Package upgrades | [`upgrade_packages.yml`](roles/server_core/tasks/upgrade_packages.yml) | `install_server_package_upgrades` | Uses `apt`, `dnf`, or `pacman` based on OS family. |
| Unattended updates | [`configure_unattended_updates.yml`](roles/server_core/tasks/configure_unattended_updates.yml) | `install_server_unattended_updates` | Uses Ubuntu unattended-upgrades, RedHat-family `dnf-automatic`, and Arch package cache maintenance. |
| tmux config | [`deploy_tmux_config.yml`](roles/server_core/tasks/deploy_tmux_config.yml) | `install_server_tmux_config` | Deploys the server tmux template. |
| zsh config | [`deploy_zsh_config.yml`](roles/server_core/tasks/deploy_zsh_config.yml) | `install_server_zsh_config` | Deploys the server zsh template. |

Server package upgrades notify the `server_core` reboot handler when package
changes are applied. Arch support intentionally avoids unattended full system
upgrades by default; it enables `paccache.timer` for package cache maintenance
instead. Run Arch package upgrades through the explicit package upgrade task or
an operator-managed maintenance window.

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
| Rclone | [`install_cloud_utilities.yml`](roles/workstation_core/tasks/install_cloud_utilities.yml) | `install_cloud_utilities` |
| Cloudflared | [`install_cloudflared.yml`](roles/workstation_core/tasks/install_cloudflared.yml) | `install_cloudflared` (off by default) |
| Cisco Secure Client | [`install_cisco_secure_client.yml`](roles/workstation_core/tasks/install_cisco_secure_client.yml) | `install_cisco_secure_client` |
| ProxyChains-NG | [`install_proxychains_ng.yml`](roles/workstation_core/tasks/install_proxychains_ng.yml) | `install_proxychains_ng` |
| LazyDocker | [`install_lazydocker.yml`](roles/workstation_core/tasks/install_lazydocker.yml) | `install_lazydocker` |
| LazyGit | [`install_lazygit.yml`](roles/workstation_core/tasks/install_lazygit.yml) | `install_lazygit` |
| Minicom | [`install_minicom.yml`](roles/workstation_core/tasks/install_minicom.yml) | `install_minicom` |
| Terraform | [`install_terraform.yml`](roles/workstation_core/tasks/install_terraform.yml) | `install_terraform` |
| Terragrunt | [`install_terragrunt.yml`](roles/workstation_core/tasks/install_terragrunt.yml) | `install_terragrunt` |
| PowerShell | [`install_powershell.yml`](roles/workstation_core/tasks/install_powershell.yml) | `install_powershell` |

Ruby is enabled by default with `install_ruby`. On Fedora, the `ruby` tag
installs system Ruby, development headers, GCC, and Make for native gem
extensions, as well as the existing user-local rbenv tooling.

Terraform and Terragrunt are enabled by default in `day0-workstation.yml` through
`workstation_core`. Run only these tools with:

```bash
ansible-playbook -i localhost, day0-workstation.yml --connection=local -K \
  --tags terraform,terragrunt
```

Terraform and Terragrunt use SHA-256-verified upstream Linux binaries on Debian
and RedHat families (including Fedora), supporting x86_64 and aarch64. Versions
are pinned by `terraform_version` and `terragrunt_version`; update those defaults
or override them in inventory to select another release. Terraform archives are
cached under `sources_dir`. Both executables install under `/usr/local/bin`.
This avoids depending on HashiCorp's release-specific APT/RPM repositories,
which may not yet support a new distro release. Existing package-managed
Terraform installations remain installed; `/usr/local/bin` normally takes
precedence in PATH. Arch uses the official packages for both tools instead.
Set `install_terraform: false` or `install_terragrunt: false` to disable either
independently. Check mode skips Terraform extraction and binary copying because
a fresh check-mode run does not download its archive.

### Workstation Desktop

Role entry point: [`roles/workstation_desktop/tasks/main.yml`](roles/workstation_desktop/tasks/main.yml)

GUI applications, desktop-specific behavior, and desktop-only AI coding CLIs.

| Feature | Task file | Toggle |
| --- | --- | --- |
| Codex CLI (npm global) | [`install_codex.yml`](roles/workstation_desktop/tasks/install_codex.yml) | `install_codex` |
| Dark appearance preference | [`install_dark_mode.yml`](roles/workstation_desktop/tasks/install_dark_mode.yml) | `install_dark_mode` |
| Claude Code (npm global) | [`install_claude_code.yml`](roles/workstation_desktop/tasks/install_claude_code.yml) | `install_claude_code` |
| JetBrainsMono Nerd Font Mono | [`install_nerd_fonts.yml`](roles/workstation_desktop/tasks/install_nerd_fonts.yml) | `install_nerd_fonts` |
| Alacritty | [`install_alacritty.yml`](roles/workstation_desktop/tasks/install_alacritty.yml) | `install_alacritty` |
| Flameshot | [`install_flameshot.yml`](roles/workstation_desktop/tasks/install_flameshot.yml) | `install_flameshot` |
| Hyprland settings | [`install_hyprland_settings.yml`](roles/workstation_desktop/tasks/install_hyprland_settings.yml) | `install_hyprland_settings` |
| Fedora Sway utilities | [`install_sway.yml`](roles/workstation_desktop/tasks/install_sway.yml) | `install_sway` |
| Regolith | [`install_regolith.yml`](roles/workstation_desktop/tasks/install_regolith.yml) | `install_regolith` |
| KDE Plasma | [`install_kde.yml`](roles/workstation_desktop/tasks/install_kde.yml) | `install_kde` |
| Chrome | [`install_chrome.yml`](roles/workstation_desktop/tasks/install_chrome.yml) | `install_chrome` |
| Microsoft Edge | [`install_microsoft_edge.yml`](roles/workstation_desktop/tasks/install_microsoft_edge.yml) | `install_microsoft_edge` |
| VSCode / Code - OSS | [`install_vscode.yml`](roles/workstation_desktop/tasks/install_vscode.yml) | `install_vscode` |
| Ulauncher (Ubuntu only) | [`install_ulauncher.yml`](roles/workstation_desktop/tasks/install_ulauncher.yml) | `install_ulauncher` |
| Qalculate GTK and Rofi calculator dependencies | [`install_qalculate.yml`](roles/workstation_desktop/tasks/install_qalculate.yml) | `install_qalculate` |
| Remmina | [`install_remmina.yml`](roles/workstation_desktop/tasks/install_remmina.yml) | `install_remmina` |
| KeePassXC | [`install_keepassxc.yml`](roles/workstation_desktop/tasks/install_keepassxc.yml) | `install_keepassxc` |

Qalculate is enabled by default on Debian, RedHat (including Fedora), and Arch
families. The `qalculate` tag installs `qalculate-gtk`, the distro's `qalc`
command-line engine, Rofi, and the native `rofi-calc` plugin.
Set `install_qalculate: false` to skip it. The dotfiles configure Sway's
`Super+C` shortcut to launch the plugin directly, with no calculator wrapper.
`Super+Shift+Space` remains available for floating mode. Results update live as
you type, using the plugin's native history and keybindings. Enter adds the
current result to history; Escape closes the calculator.
Arch uses its packaged `rofi-calc`; Debian and
RedHat families build the pinned `rofi_calc_version` into `~/.local/lib/rofi`
using distro development packages. Build sources are cached under `sources_dir`.
Rerun the tag after upgrading Rofi to rebuild for its plugin ABI. Check mode
skips source checkout and compilation. Launch the standalone Qalculate GTK app
from the normal application launcher when you want the full calculator UI.

```bash
ansible-playbook -i localhost, day0-workstation.yml --connection=local -K \
  --tags qalculate,dotfiles
```

Dark appearance is enabled by default on Debian, RedHat (including Fedora), and
Arch families. The `dark_mode` tag installs the dconf dependencies and sets
`org.gnome.desktop.interface color-scheme` to `prefer-dark` for the user running
Ansible. Run from your normal desktop account, without `sudo` on the playbook
command; only dependency installation uses privilege escalation. Set
`install_dark_mode: false` to skip it.

```bash
ansible-playbook -i localhost, day0-workstation.yml --connection=local -K \
  --tags dark_mode
```

This sets the GNOME/GTK preference, including for Sway and Hyprland apps that
consume it. It does not select a legacy GTK theme or configure KDE Plasma's
native color scheme. Apps using the appearance portal need a Settings-capable
portal backend, such as `xdg-desktop-portal-gtk` on Sway, configured by the
desktop. Restart apps or log in again if they do not pick up the change.

Query the stored preference from a terminal in your desktop session:

```bash
gsettings get org.gnome.desktop.interface color-scheme
```

To query the preference exposed to applications through the desktop portal:

```bash
gdbus call --session --dest org.freedesktop.portal.Desktop \
  --object-path /org/freedesktop/portal/desktop \
  --method org.freedesktop.portal.Settings.Read \
  org.freedesktop.appearance color-scheme
```

The portal value is `0` for no preference, `1` for dark, and `2` for light.
The stored setting and portal response can differ if the desktop's Settings
backend uses another source.

Nerd Fonts are enabled by default for desktop installations. The `nerd_fonts`
tag installs the regular, bold, italic, and bold italic JetBrainsMono Nerd Font
Mono faces under `~/.local/share/fonts/JetBrainsMono` and refreshes the font
cache only when extraction changes files. The architecture-independent upstream
archive is pinned with `nerd_fonts_version` and verified against its published
SHA-256 checksum. Debian, RedHat, and Arch use the same installation path.
Set `install_nerd_fonts: false` to skip it. Alacritty's font selection is managed
in the dotfiles repository. Check mode skips extraction and cache refresh.

```bash
ansible-playbook -i localhost, day0-workstation.yml --connection=local -K \
  --tags nerd_fonts
```

Codex and Claude Code are enabled by default only in the desktop role. Both use
`npm -g` through the existing user-local NVM installation without sudo, with the
same installation tasks across Debian, RedHat, and Arch families. Keep
`install_nodejs: true` enabled to provide the configured Node.js runtime.
For a fresh host running only these tags, include Node.js setup:

```bash
ansible-playbook -i localhost, day0-workstation.yml --connection=local \
  --tags nodejs,codex,claude_code
```

Disable them independently with `install_codex: false` or
`install_claude_code: false`. Launch `codex` or `claude` after installation to
complete authentication.

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
- Server unattended updates are distro-specific: Ubuntu uses
  `hifis.unattended_upgrades`, RedHat-family hosts use `dnf-automatic`, and
  Arch only enables package cache maintenance by default.
- Arch work should be tested against Omarchy unless a task explicitly targets
  generic Arch. Prefer official pacman packages where possible.
- AUR support is limited to specific application tasks that need it.
- Desktop environment installs should be opt-in unless they are lightweight app
  installs.

For more detailed agent guidance, see [`AGENTS.md`](AGENTS.md).
