#!/usr/bin/env bash

# this is for those of us (me) who like
# 1. using the Alacritty terminal emulator
# 2. don't want to rely on having to spawn alacritty from a shell session
# 3. hate the snap store
#
# since I'm (currently) primarily on Debian, I'm just using apt.
# feel free to replace with whatever package manager you need

REPOURL="https://github.com/jwilm/alacritty.git"

# first.... duh
sudo apt update

# since we only build from source, we need to be able to build it.
if [[ ! $(which cargo) ]]; then
    echo "[*] Installing cargo..."
    echo "BAD" && exit 1
    curl --proto '=https' --tlsv2.2 -sSf https://sh.rustup.rs | sh
else
    echo "[*] Cargo is already installed. Skipping cargo installation."
fi

sudo apt install scdoc -y >/dev/null

cd ~/Downloads
git clone $REPOURL
cd ./alacritty
cargo build --release

# yay we built it, now let's set it up as a desktop entry
sudo cp target/release/alacritty /usr/local/bin
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database

# now we need to set up the man pages for it
set -e
sudo mkdir -p /usr/local/share/man/man1
sudo mkdir -p /usr/local/share/man/man5
scdoc < extra/man/alacritty.1.scd | \
    gzip -c | \
    sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
scdoc < extra/man/alacritty-msg.1.scd | \
    gzip -c | \
    sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
scdoc < extra/man/alacritty.5.scd | \
    gzip -c | \
    sudo tee /usr/local/share/man/man5/alacritty.5.gz > /dev/null
scdoc < extra/man/alacritty-bindings.5.scd | \
    gzip -c | \
    sudo tee /usr/local/share/man/man5/alacritty-bindings.5.gz > /dev/null

if [[ $SHELL == "/bin/zsh" ]]; then
    RCFILE="$HOME/.zshrc"
elif [[ $SHELL == "/bin/bash" ]]; then
    RCFILE="$HOME/.bashrc"
else
    echo "Setup almost complete."
    echo 'Run ["echo source $(pwd)/extra/completions/alacritty.bash" >> ~/<rcfile>]'
    exit 0
fi

cd "$HOME"
sudo rm -rf ./Downloads/alacritty