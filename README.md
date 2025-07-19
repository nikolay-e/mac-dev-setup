# mac-dev-setup 

My personal configuration for a productive development workstation on macOS. This repository contains configurations, aliases, and scripts to automate setup on a new machine.

## Installation

This setup assumes you have Git and the GitHub CLI (`gh`) installed.

1.  **Clone the repository:**
    ```bash
    gh repo clone nikolay-e/mac-dev-setup
    ```

2.  **Run the installation script:**
    ```bash
    cd mac-dev-setup
    ./install.sh
    ```

## File Structure

* **`.zshrc`**: The main configuration file for Zsh. It sets shell options and sources the aliases file.
* **`.aliases`**: A dedicated file containing all shell aliases for Git, navigation, and other utilities. This keeps `.zshrc` clean.
* **`install.sh`**: The automated setup script. It installs Homebrew packages and creates symbolic links for the configuration files.

---
This project is managed by [Nikolay-E](https://github.com/nikolay-e).