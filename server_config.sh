#!/bin/sh

sudo apt-get install git screen tmux locate zsh libboost-all-dev -y
cd /root


##REDIS
wget http://download.redis.io/releases/redis-4.0.9.tar.gz
tar xzf redis-4.0.9.tar.gz

cd redis-4.0.9
make
make install
status = $_
if [[ "$status" != 0 ]] 
then
	make install
else
	echo "Error make test REDIS\n"
	read -p "Continue?" yn
	case $yn in
	[Nn]* ) exit;;
	esac
fi
echo "Redis installed...\n"

echo 'vm.overcommit_memory=1' » /etc/sysctl.conf
echo 'sysctl -w net.core.somaxconn=15000' » /etc/rc.local
echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' » /etc/rc.local
sysctl vm.overcommit_memory=1
sysctl -w net.core.somaxconn=15000
echo never > /sys/kernel/mm/transparent_hugepage/enabled

echo "Redis system optimisation tuned\n"

##NODE
curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash 
sudo apt-get install -y nodejs
status = $_
if [ "$status" != 0 ] 
then
	echo "Node succefully installed"
else
	echo "Error installing NODEJS\n"
	read -p "Continue?" yn
	case $yn in

	[Nn]* ) exit;;
	esac
	
fi
sudo apt-get install build-essential libsodium-dev -y
sudo npm install n -g
sudo n stable
echo "Stable NODE is activated, cloning Z-NOMP\n"
cd
git clone https://github.com/joshuayabut/node-open-mining-portal.git z-nomp
cd z-nomp

npm update
npm install
status = $_
if [ "$status" != 0 ] 
then
	echo "Z-NOMP is installed\n"
else
	echo "Error installing Z-NOMP\n"
	read -p "Continue?" yn
	case $yn in

	[Nn]* ) exit;;
	esac
fi
echo "Installing FOREVER\n"
npm i forever -g

echo "Installing NETDATA\n"
sudo apt-get install git zlib1g-dev uuid-dev libmnl-dev gcc make autoconf autoconf-archive autogen automake pkg-config curl -y
sudo apt-get install python python-yaml python-mysqldb python-psycopg2 nodejs lm-sensors netcat -y
if [ "$status" != 0 ] 
then
	echo "NETDATA dependencies are installed\n"
else
	echo "Error installing NETDATA deps\n"
	read -p "Continue?" yn
	case $yn in
	[Nn]* ) exit;;
	esac
fi
echo "Cloning NETDATA\n"
git clone https://github.com/firehol/netdata.git --depth=1 ~/netdata
cd ~/netdata
sudo ./netdata-installer.sh
pid=`ps auxw | grep netdata | head -n1 | awk '{print $2}'`
kill $pid

sed -e 's/#\s*history.*/history=86400/' /etc/netdata/netdata.conf > /tmp/netdata.conf
\cp -r /tmp/netdata.conf /etc/netdata.conf
netdata
##END
updatedb
echo "Finished\n"

sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
source ~/.zshrc
