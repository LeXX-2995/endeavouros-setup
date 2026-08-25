# EndeavourOS / Arch workstation setup

Personal, repeatable workstation setup for EndeavourOS and Arch Linux.

The scripts install:

- `yay` (kept if installed, installed with `pacman` on EndeavourOS, or built
  from AUR as a fallback on plain Arch);
- Fish as the default shell, with a small unbranded user configuration;
- CLI and development tools, .NET workloads, and desktop applications;
- the official ChatGPT desktop application through its current AUR package;
- E-IMZO, its certificate, desktop entry, and autostart entry;
- `fprintd`/`libfprint` support for the fingerprint reader;
- a generic user SSH agent, without personal keys or host configuration.

## Run

Run the complete base setup as your normal user:

```bash
./run-all.sh
```

Do not run the scripts with `sudo`; they request elevated privileges only for
the operations that need them.

Personal SSH keys, host aliases, private repository URLs, and work-specific
configuration should be kept in a separate private setup repository. Never
commit the private-key material itself, even to that repository.

## Individual scripts

The numeric prefixes define the intended order. Every package-install command
uses `--needed`, so the scripts can be run again when required.

Fingerprint templates cannot be transferred between installations. After
running `32-fingerprint.sh`, enroll a finger in KDE Plasma under **System
Settings -> Users -> Configure Fingerprint Authentication**, or run
`fprintd-enroll` in a terminal. Use `fprintd-verify` to test it.

The fingerprint script also enables fingerprint-or-password authentication
only for `sudo`. It keeps the original PAM configuration at
`/etc/pam.d/sudo.pre-fingerprint`. Be aware that fingerprint authentication
for privilege elevation has a known attention/hijacking risk; do not touch the
reader unless you initiated the `sudo` request yourself.
