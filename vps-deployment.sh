#!/bin/bash

if [ "$1" == "" ]; then
  echo "Usage: `basename $0` $USER"
  exit 0
fi

if [ "$(id -u)" != "0" ]; then
        echo "Please run using sudo."
        exit 1
fi

echo -e "\e[1;31mSetting Permissions...\e[0m"
sudo -H -u $1 bash -c 'chmod 0750 $HOME'

echo -e "\e[1;31mUpdating and installing packages...\e[0m"
apt-get update && apt-get -y upgrade
apt-get -y install lsb-release scrot vim openssh-server ufw build-essential checkinstall libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libpython-stdlib libpython2.7-minimal libpython2.7-stdlib python python-minimal python2.7 python2.7-minimal python3 python3-pip python-dev curl openssh-server git

sudo -H -u $1 bash -c 'mkdir $HOME/Downloads'
cd $HOME/Downloads

echo -e "\e[1;31mDownloading Archey...\e[0m"
sudo -H -u $1 bash -c 'wget -P $HOME/Downloads/ http://github.com/downloads/djmelik/archey/archey-0.2.8.deb'
sudo dpkg -i $HOME/Downloads/archey-0.2.8.deb

echo -e "\e[1;31mDownloading Pip...\e[0m"
sudo -H -u $1 bash -c 'wget -P $HOME/Downloads/ https://bootstrap.pypa.io/get-pip.py'
python $HOME/Downloads/get-pip.py

cd $HOME
sudo -H -u $1 bash -c 'echo "archey" >> $HOME/.bashrc'
sudo -H -u $1 bash -c 'echo "alias vi='vim'" >> $HOME/.bashrc'
sudo -H -u $1 bash -c 'echo "alias speedtest=\"curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -\"" >> $HOME/.bashrc'
sudo -H -u $1 bash -c 'echo ":color desert" >> $HOME/.vimrc'
sudo -H -u $1 bash -c 'rm -r $HOME/Downloads/'

sudo -H -u $1 bash -c 'echo "PS1=\"${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ $RS \"" >> $HOME/.bashrc # green'

echo -e "\e[1;31mSetting Skel...\e[0m"
echo "archey" >> /etc/skel/.bashrc
echo "alias vi='vim'" >> /etc/skel/.bashrc
echo ":color desert" >> /etc/skel/.vimrc
echo "PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ $RS '" >> /etc/skel/.bashrc # green

/bin/echo -e "\e[1;31mUFW Settings\e[0m"
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
echo y | ufw enable
