#!/bin/bash

set -e

date

#################################################################
# Update Ubuntu and install prerequisites for running VapeCoin   #
#################################################################
sudo apt-get update
#################################################################
# Build VapeCoin from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building VapeCoin           #
#################################################################
sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

# By default, assume running within repo
repo=$(pwd)
file=$repo/src/vapecoind
if [ ! -e "$file" ]; then
	# Now assume running outside and repo has been downloaded and named vapecoin
	if [ ! -e "$repo/vapecoin/build.sh" ]; then
		# if not, download the repo and name it vapecoin
		git clone https://github.com/VapeCoinDev/Vapecoin-Master.git vapecoin
	fi
	repo=$repo/vapecoin
	file=$repo/src/vapecoind
	cd $repo/src/
fi
make -j$NPROC -f makefile.unix

cp $repo/src/vapecoind /usr/bin/vapecoind

################################################################
# Configure to auto start at boot                                      #
################################################################
file=$HOME/.vapecoin
if [ ! -e "$file" ]
then
        mkdir $HOME/.vapecoin
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | tee $HOME/.vapecoin/vapecoin.conf
file=/etc/init.d/vapecoin
if [ ! -e "$file" ]
then
        printf '%s\n%s\n' '#!/bin/sh' 'sudo vapecoind' | sudo tee /etc/init.d/vapecoin
        sudo chmod +x /etc/init.d/vapecoin
        sudo update-rc.d vapecoin defaults
fi

/usr/bin/vapecoind
echo "VapeCoin has been setup successfully and is running..."

