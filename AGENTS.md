# AGENTS.md

This repository is an Ansible "day 0" bootstrap project for configuring Linux
servers and personal workstations. It installs baseline CLI tooling, shells,
developer tools, desktop applications, and selected user configuration from a
fresh or minimally configured Linux install.

The current implementation started with Ubuntu/Debian as the primary target and
has partial RedHat-family support. New work should move the playbooks toward
cross-distro behavior without breaking the existing Ubuntu workstation flow.

## Repository Map

- `day0-workstation.yml` is the workstation entry point. It applies `common`,
  `workstation_core`, and `workstation_desktop`.
- `day0-server.yml` is the server entry point. It applies `common` and
  `server_core`.
- `install-workstation.sh` runs the workstation playbook locally against
  `localhost,` with `--connection=local`.
- `bootstrap.sh` installs Ansible and Galaxy requirements for supported host
  distributions.
- `ansible.cfg` sets Python to `/usr/bin/python3`, disables host key checking,
  and disables retry files.
- `inventory/` contains sample inventories for remote server playbook runs.
- `roles/requirements.yml` declares Galaxy collections and roles:
  `community.general`, `community.crypto`, `hifis.unattended_upgrades`, and
  `geerlingguy.repo-epel`.

## Role Structure

The roles follow a simple include-file pattern:

- `roles/common` contains packages and configuration shared by servers and
  workstations.
- `roles/server_core` contains server-only configuration such as hostname,
  unattended upgrades, tmux, and zsh templates.
- `roles/workstation_core` contains workstation developer tooling and CLI
  applications.
- `roles/workstation_desktop` contains GUI and desktop-environment packages.

Each role's `tasks/main.yml` should remain a readable list of
`ansible.builtin.include_tasks` entries. Each included task file should have:

- A matching default variable in `defaults/main.yml`, usually named
  `install_<feature>`.
- A `when:` guard in `tasks/main.yml` using that default variable.
- A clear tag matching the feature, such as `docker`, `neovim`, or `vscode`.

Example pattern:

```yaml
- name: Install go
  ansible.builtin.include_tasks:
    file: install_go.yml
  when: install_go | default(true)
  tags: go
```

## Development Guidelines

- Prefer built-in Ansible modules over shell commands. Use `package`,
  `apt`, `dnf`, `apt_repository`, `rpm_key`, `get_url`, `unarchive`, `git`,
  `file`, `template`, `user`, and `systemd_service` where possible.
- Use `ansible.builtin.shell` or `ansible.builtin.command` only when there is
  no good module equivalent. Make command tasks idempotent with `creates:`,
  `removes:`, `changed_when:`, or a prior check task.
- Use `become: true` only for system-level changes. User-local installs under
  `{{ ansible_env.HOME }}` should normally run without privilege escalation.
- Keep task names explicit and user-facing. A failed run should make it obvious
  which feature and distro path failed.
- Keep files ASCII unless an existing file clearly requires Unicode.
- Do not rewrite unrelated roles or installer scripts while adding one feature.
- Preserve user-local paths such as `{{ ansible_env.HOME }}` and existing
  conventions like `sources_dir`.

## Cross-Distro Rules

When adding or updating tasks, treat cross-platform support as a first-class
requirement.

- Branch on Ansible facts, usually `ansible_facts['os_family']`, for broad
  behavior:
  - `Debian` covers Ubuntu, Debian, Pop!_OS, Linux Mint, and similar systems.
  - `RedHat` covers RHEL, Rocky, AlmaLinux, Fedora, and similar systems.
- Use `ansible_distribution`, `ansible_distribution_major_version`, and
  `ansible_distribution_release` only when a repository or package source
  genuinely differs by distro or release.
- Prefer `ansible.builtin.package` for packages with the same name across
  distros.
- Use `ansible.builtin.apt` only for Debian-specific behavior such as `.deb`
  files, apt cache updates, or apt-only package names.
- Use `ansible.builtin.dnf` for RedHat-family package installs that require DNF
  behavior, local RPM files, or DNF-specific options.
- Do not assume Ubuntu repositories for every Debian-family host. If an upstream
  repository is Ubuntu-only, guard it with `ansible_distribution == 'Ubuntu'` or
  provide a Debian-safe path.
- Do not hard-code a release such as `noble` unless the upstream repository only
  supports that release and the task is guarded accordingly. Prefer
  `{{ ansible_distribution_release }}` when safe.
- Avoid Snap as the only cross-distro answer unless the application is truly
  distributed that way here. RedHat-family Snap setup currently lives in
  `roles/common/tasks/install_snapd.yml`.
- For GitHub release binaries, verify asset naming across architecture and OS.
  `workstation_core` currently sets `system_arch` from `uname -s` and
  `uname -m`, producing values like `Linux_x86_64`.
- Use architecture-aware URLs or facts when downloading `.deb`, `.rpm`, or
  tarball assets. Avoid assuming `amd64`/`x86_64` unless the task is guarded.

## Existing Portability Hotspots

The following areas are known to need care when making the repo more
cross-platform:

- `bootstrap.sh` already branches for `ubuntu`, `rocky`, `rhel`, and `arch`.
  Keep bootstrap support aligned with playbook support.
- `roles/common/tasks/install_packages.yml` mixes `package`, `apt`, and Snap.
  New baseline packages should use `package` when names match.
- `roles/server_core/meta/main.yml` configures Ubuntu unattended-upgrades
  origins. Guard or replace this before claiming general RedHat support for
  `day0-server.yml`.
- `roles/workstation_core/tasks/install_docker.yml` supports Debian and RedHat
  families, but the Debian repository URL currently points at Ubuntu.
- `roles/workstation_core/tasks/install_terraform.yml` is Debian-only and uses a
  hard-coded `noble` release.
- Several desktop tasks are Debian-only, while Chrome and VSCode already include
  both Debian and RedHat paths.
- Some desktop tasks have commented RedHat/Snap placeholders. Prefer replacing
  placeholders with tested distro-specific task blocks.

## Adding A New Feature

1. Decide which role owns the feature:
   - Shared server/workstation package: `common`
   - Server-only behavior: `server_core`
   - Workstation CLI/developer tool: `workstation_core`
   - GUI app or desktop environment: `workstation_desktop`
2. Add an `install_<feature>: true` default to the role's `defaults/main.yml`.
3. Add an include block to the role's `tasks/main.yml` with a matching tag.
4. Create `tasks/install_<feature>.yml`.
5. Use distro-aware blocks inside that task file:

```yaml
- name: Install example package on common package managers
  become: true
  ansible.builtin.package:
    name: example
    state: present
  when: ansible_facts['os_family'] in ['Debian', 'RedHat']
  tags: example
```

6. If package names differ, prefer variables or separate named tasks over Jinja
   conditionals embedded inside long package lists.
7. Add templates under `templates/` only when a feature deploys config files.
8. Update `README.md` when the user-facing feature list or run instructions
   change.

## Idempotency Expectations

All tasks should be safe to run repeatedly.

- Package installs should use `state: present`.
- Downloads should use stable destinations under `/tmp` or `{{ sources_dir }}`
  and clean up temporary archives when appropriate.
- Source builds should compare installed versions before rebuilding where
  practical.
- Repository/key setup should not report changed on every run.
- Check tasks such as `command: tool --version` should use
  `changed_when: false` and usually `ignore_errors: true`.
- Command tasks that only probe state must never mark the play changed.

## Verification

Run the smallest useful check for the change. Recommended commands:

```bash
ansible-playbook -i localhost, day0-workstation.yml --connection=local --syntax-check
ansible-playbook -i localhost, day0-server.yml --connection=local --syntax-check
ansible-playbook -i localhost, day0-workstation.yml --connection=local --check --tags <tag>
```

For feature-specific work, use tags to limit blast radius:

```bash
ansible-playbook -i localhost, day0-workstation.yml --connection=local --check --tags docker
```

If `ansible-lint` is available, run it before finishing:

```bash
ansible-lint
```

Do not run full local installation playbooks without confirming intent, because
they can install packages, change shell configuration, and reboot via wrapper
scripts.

## Notes For LLM Agents

- Read `README.md`, the relevant role defaults, and the role's `tasks/main.yml`
  before editing.
- Search existing task files for a similar installer before inventing a new
  pattern.
- Keep changes narrow and review `git diff` before finishing.
- Be careful with `bootstrap.sh`; it may contain local work in progress.
- Do not remove or reset user changes. This repo may have a dirty worktree.
- Prefer improving one feature end-to-end over broad partial rewrites.
