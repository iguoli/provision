#!/usr/bin/env bash

# Replace the offical yum repo with the UTSC mirror's repo
sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=|baseurl=|g' \
    -e 's|^baseurl=http://mirror.centos.org/$contentdir/$releasever|baseurl=https://mirrors.ustc.edu.cn/centos/8-stream|g' \
    -i.bak \
    /etc/yum.repos.d/CentOS-Linux-AppStream.repo \
    /etc/yum.repos.d/CentOS-Linux-BaseOS.repo \
    /etc/yum.repos.d/CentOS-Linux-Extras.repo \
    /etc/yum.repos.d/CentOS-Linux-PowerTools.repo \
    /etc/yum.repos.d/CentOS-Linux-Plus.repo

# Replace the Fedora EPEL repo with the UTSC mirror's repo
sed -e 's|^metalink=|#metalink=|g' \
    -e 's|^#baseurl=https\?://download.fedoraproject.org/pub/epel/|baseurl=https://mirrors.ustc.edu.cn/epel/|g' \
    -e 's|^#baseurl=https\?://download.example/pub/epel/|baseurl=https://mirrors.ustc.edu.cn/epel/|g' \
    -i.bak \
    /etc/yum.repos.d/epel.repo

yum makecache

# Install git and proxy utils
yum install -y git connect-proxy proxychains-ng

# Install and set ZSH as default shell of vagrant user
yum install -y zsh util-linux-user
which zsh | sudo tee -a /etc/shells
chsh -s "$(which zsh)" vagrant

# Install oh-my-zsh and plugins
su - vagrant -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
su - vagrant -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
su - vagrant -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'

# Install vim-plug
su - vagrant -c 'curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# Install pygments
yum install -y python3-pygments

# Install grc
git clone https://github.com/garabik/grc.git
cd grc
./install.sh
cd ..
rm -rf grc

# Customize .zshrc file for vagrant user
su - vagrant -c \
    'sed -e "s|^plugins=(git)|plugins=(git perl zsh-autosuggestions zsh-syntax-highlighting common-aliases z vi-mode)|" \
         -e "/^# HYPHEN_INSENSITIVE/s//HYPHEN_INSENSITIVE/" \
         -e "/^#\s\+if/,+4 {s/^#\s//}" \
         -e "/^# User configuration/a\
# Set options for GNU less\\
# --quit-if-one-screen --ignore-case --status-column\\
# --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD\\
# --tabs=4 --no-init --window=-4\\
export LESS=\"-F -i -J -M -R -W -x4 -X -z-4\"\\
export LESSOPEN=\"|/usr/bin/pygmentize -g -O style=colorful %s\"" \
         -e "\$a\[[ -s /etc/grc.zsh ]] && source /etc/grc.zsh" \
         -i.bak \
         ~/.zshrc'

# Disable SELINUX
# sed -i -e 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# Enable the web application to access database
setsebool -P httpd_can_network_connect_db on

# Open services access in firewalld
firewall-cmd --add-service=http --add-service=https --add-service=postgresql
firewall-cmd --add-service=http --add-service=https --add-service=postgresql --permanent
