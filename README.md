# campus-ntc (legacy)

[![GitHub release](https://img.shields.io/github/v/release/soppylzz/campus-ntc)](https://github.com/soppylzz/campus-ntc/releases) ![zsh](https://img.shields.io/badge/shell-zsh-89E051)

An archived zsh command-line tool for logging in to and out of the CQUPT campus network. It supports multiple user profiles and English or Chinese terminal output. This repository is no longer maintained.

## Requirements

- Linux or macOS with zsh installed
- A terminal that supports Unicode and color output

## Installation

Clone the repository and run its installer, which links `cntc` into `~/.local/bin`:

```sh
git clone --depth 1 https://github.com/soppylzz/campus-ntc.git "$HOME/.local/share/campus-ntc"
zsh "$HOME/.local/share/campus-ntc/src/zsh/install.sh"
```

If needed, add `~/.local/bin` to your shell's `PATH`:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

Create the initial configuration, then use `cntc` to manage accounts and connections:

```sh
cntc configure
cntc user
cntc login
cntc logout
cntc --help
```

| Command | Purpose |
| --- | --- |
| `config` | Edit global settings from the command line |
| `configure` | Configure global settings interactively |
| `user` | Manage campus-network accounts |
| `login` / `logout` | Connect to or disconnect from the campus network |
| `--version` | Show the installed version |

## Uninstall

```sh
zsh "$HOME/.local/share/campus-ntc/src/zsh/uninstall.sh"
rm -rf "$HOME/.local/share/campus-ntc"
```

## License

[MIT](./LICNESE).
