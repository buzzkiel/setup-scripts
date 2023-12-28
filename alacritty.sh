#!/usr/bin/env bash

# this is for those of us (me) who like
# 1. using the Alacritty terminal emulator
# 2. don't want to rely on having to spawn alacritty from a shell session
# 3. hate the snap store
#
# since I'm (currently) primarily on Debian, I'm just using apt.
# feel free to replace with whatever package manager you need

if [[ $EUID -ne 0 ]]; then
    echo "Please run as root </3"
    exit 1
fi

REPOURL="https://github.com/jwilm/alacritty.git"

# first.... duh
apt update

# since we only build from source, we need to be able to build it.
if [[ ! $(which cargo) ]]; then
    echo "[*] Installing cargo..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

cd ~/Downloads
git clone $REPOURL
cd ./alacritty
cargo build --release

# yay we build it, now let's set it up as a desktop entry
cp target/release/alacritty /usr/local/bin
cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
desktop-file-install extra/linux/Alacritty.desktop
update-desktop-database

# now we need to set up the man pages for it
mkdir -p /usr/local/share/man/man1
gzip -c extra/alacritty.man |
    tee /usr/local/share/man/man1/alacritty.1.gz >/dev/null

if [[ $SHELL == "/bin/zsh" ]]; then
    RCFILE="~/.zshrc"
elif [[ $SHELL == "/bin/bash" ]]; then
    RCFILE="~/.bashrc"
else
    echo "Setup almost complete."
    echo 'Run ["echo source $(pwd)/extra/completions/alacritty.bash" >> ~/<rcfile>]'
    exit 0
fi
