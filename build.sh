#!/bin/bash
set -e

# Clean up first
sudo rm -rf ~/.local/var/pmbootstrap
rm -rf out
rm -rf pmbootstrap

# Git identity
git config --global user.email "example@example.com"
git config --global user.name "Nonta72"

# Replace placeholders in .cfg file
find . -type f -name "*.cfg" -exec sed -i "s|HOME|$(echo $HOME)|;s|NPROC|$(nproc)|" {} +

# Setup environment
export KERNEL_BRANCH=danila/spacewar-testing

# Install pmbootstrap from Git
git clone https://gitlab.postmarketos.org/postmarketOS/pmbootstrap.git --depth 1
mkdir -p ~/.local/bin
export PATH="$PATH:~/.local/bin"
sudo rm /home/ubuntu/.local/bin/pmbootstrap
ln -s "$PWD/pmbootstrap/pmbootstrap.py" ~/.local/bin/pmbootstrap
pmbootstrap --version

# Init
echo -e '\n\n' | pmbootstrap init || true
cd ~/.local/var/pmbootstrap/cache_git/pmaports

# Kernel branch setup
export DEFAULT_BRANCH=danila/spacewar-mr
git remote add sc7280 https://github.com/mainlining/pmaports.git
git fetch sc7280 $DEFAULT_BRANCH
git reset --hard sc7280/$DEFAULT_BRANCH
export DEFAULT_BRANCH=danila/spacewar-testing
echo "Default branch is $DEFAULT_BRANCH"
git clone https://github.com/mainlining/linux.git --single-branch --branch $KERNEL_BRANCH --depth 1

# Copy config to pmbootstrap
cp /home/ubuntu/pmos/nothing-spacewar.cfg ~/.config/pmbootstrap_v3.cfg

# Compile kernel image
cd linux
shopt -s expand_aliases
source /home/ubuntu/pmos/pmbootstrap/helpers/envkernel.sh
make defconfig sc7280.config
make -j$(nproc)
pmbootstrap build --envkernel linux-postmarketos-qcom-sc7280

# Build pmos images
cp /home/ubuntu/pmos/nothing-spacewar.cfg ~/.config/pmbootstrap.cfg
pmbootstrap install --password 1114

# Export build images to outdir
pmbootstrap export
mkdir /home/ubuntu/pmos/out

cp /tmp/postmarketOS-export/boot.img /home/ubuntu/pmos/out/boot-nothing-spacewar.img
cp /tmp/postmarketOS-export/nothing-spacewar.img /home/ubuntu/pmos/out/rootfs-nothing-spacewar.img
tar -c -I 'xz -9 -T0' -f /home/ubuntu/pmos/out/Spacewar_pmos.tar.xz /home/ubuntu/pmos/out/rootfs-nothing-spacewar.img /home/ubuntu/pmos/out/boot-nothing-spacewar.img
echo -e "n\nn\ny\n" | pmbootstrap zap
