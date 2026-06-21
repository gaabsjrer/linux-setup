mkdir -p ~/git
cd ~/git
sudo apt-get -y install git
git clone https://github.com/LASER-Robotics/linux-setup.git
git clone https://github.com/LASER-Robotics/linux-setup-extras.git
cd linux-setup
./install.sh
cd ~/git/linux-setup-extras
../install.sh
