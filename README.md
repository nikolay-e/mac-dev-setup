# mac-dev-setup 

A robust configuration for a productive development workstation on macOS.

This project automates the installation of essential tools and safely integrates with your existing shell setup. It is designed to be **idempotent**, meaning you can run it multiple times without breaking your configuration.

## Installation

```bash
cd mac-dev-setup
./install.sh
```

## How It Works

* **Tool Installation**: Installs a comprehensive suite of CLI tools and GUI applications using Homebrew.
* **Project Aliases**: Creates a symlink from `~/.mac-dev-setup-aliases` to the alias file in this repository. The unique name prevents conflicts with other alias files.
* **Robust Configuration**: The script intelligently checks your `~/.zshrc` for a configuration block marked with a unique comment. If the block is not found, it appends all necessary environment settings (for NVM, Pyenv, etc.) and sources the alias file. This ensures your custom `~/.zshrc` is never overwritten.

---
This project is managed by [Nikolay-E](https://github.com/nikolay-e).