#!/bin/bash

if [ "$1" == "" ]; then
  echo "Usage: `basename $0` \"<SSH Public Key>\""
  exit 0
fi

if [ "$(id -u)" != "0" ]; then
        echo "Please run using sudo."
        exit 1
fi

/bin/echo -e "\e[1;31mSetting Permissions...\e[0m"
chmod 0750 $HOME

/bin/echo -e "\e[1;31mUpdating and installing packages...\e[0m"
apt-get update && apt-get -y upgrade
apt-get -y install lsb-release scrot vim openssh-server build-essential checkinstall libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libpython-stdlib libpython2.7-minimal libpython2.7-stdlib python python-minimal python2.7 python2.7-minimal curl openssh-server ufw git

mkdir $HOME/Downloads
cd $HOME/Downloads

/bin/echo -e "\e[1;31mDownloading Archey...\e[0m"
wget -P $HOME/Downloads/ http://github.com/downloads/djmelik/archey/archey-0.2.8.deb
dpkg -i $HOME/Downloads/archey-0.2.8.deb 

/bin/echo -e "\e[1;31mDownloading Pip...\e[0m"
wget -P $HOME/Downloads/ https://bootstrap.pypa.io/get-pip.py
python $HOME/Downloads/get-pip.py

cd $HOME
echo "archey" >> $HOME/.bashrc
echo "alias vi='vim'" >> $HOME/.bashrc
echo ":color desert" >> $HOME/.vimrc
rm -r $HOME/Downloads/

echo "PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ $RS '" >> .bashrc # green

/bin/echo -e "\e[1;31mSetting Skel...\e[0m"
echo "archey" >> /etc/skel/.bashrc
echo "alias vi='vim'" >> /etc/skel/.bashrc
echo ":color desert" >> /etc/skel/.vimrc
echo "PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ $RS '" >> /etc/skel/.bashrc # green

/bin/echo -e "\e[1;31mSSH Settings...\e[0m"
mkdir $HOME/.ssh
echo $1 >> $HOME/.ssh/authorized_keys
rm /etc/ssh/sshd_config
echo "Port 22" >> /etc/ssh/sshd_config
echo "Protocol 2" >> /etc/ssh/sshd_config
echo "HostKey /etc/ssh/ssh_host_rsa_key" >> /etc/ssh/sshd_config
echo "HostKey /etc/ssh/ssh_host_dsa_key" >> /etc/ssh/sshd_config
echo "HostKey /etc/ssh/ssh_host_ecdsa_key" >> /etc/ssh/sshd_config
echo "HostKey /etc/ssh/ssh_host_ed25519_key" >> /etc/ssh/sshd_config
echo "UsePrivilegeSeparation yes" >> /etc/ssh/sshd_config
echo "KeyRegenerationInterval 3600" >> /etc/ssh/sshd_config
echo "ServerKeyBits 2048" >> /etc/ssh/sshd_config
echo "SyslogFacility AUTH" >> /etc/ssh/sshd_config
echo "LogLevel INFO" >> /etc/ssh/sshd_config
echo "LoginGraceTime 120" >> /etc/ssh/sshd_config
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "StrictModes yes" >> /etc/ssh/sshd_config
echo "RSAAuthentication yes" >> /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "IgnoreRhosts yes" >> /etc/ssh/sshd_config
echo "RhostsRSAAuthentication no" >> /etc/ssh/sshd_config
echo "HostbasedAuthentication no" >> /etc/ssh/sshd_config
echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config
echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "X11Forwarding yes" >> /etc/ssh/sshd_config
echo "X11DisplayOffset 10" >> /etc/ssh/sshd_config
echo "PrintMotd no" >> /etc/ssh/sshd_config
echo "PrintLastLog yes" >> /etc/ssh/sshd_config
echo "TCPKeepAlive yes" >> /etc/ssh/sshd_config
echo "AcceptEnv LANG LC_*" >> /etc/ssh/sshd_config
echo "Subsystem sftp /usr/lib/openssh/sftp-server" >> /etc/ssh/sshd_config
echo "UsePAM yes" >> /etc/ssh/sshd_config
chown $USER:$USER -R $HOME/.ssh

/bin/echo -e "\e[1;31mRestarting SSH Service\e[0m"
service ssh restart

/bin/echo -e "\e[1;31mUFW Settings\e[0m"
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
echo y | ufw enable
