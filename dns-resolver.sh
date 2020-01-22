#!/bin/bash
:<<'END_COMMENT'
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
    created by VirtualDemon : https://github.com/virtualdemon/code-examples/blob/master/bashScripting/dns-fixer/dns-resolver.sh '
END_COMMENT
configFile='/etc/NetworkManager/NetworkManager.conf'
resolvConf='/etc/resolv.conf'

function configFileExistence {
	if [ ! -e $configFile ] ; then
		echo -e "Config file doesn't exist, please install NetworkManager\n"
		exit
	fi	
}
function configureNetworkManager {
	if [[ ! $(grep '[main]' $configFile) ]]; then
		echo "Adding '[main]' section into $configFile"
		sudo sed -i '1 a [main]' $configFile
	fi
	if [[ ! $(grep 'dns=none' $configFile) ]] ; then
		echo "Adding 'dns=none' into $configFile"
		sudo sed -i '/[main]/ a dns=none' $configFile
	fi
}
function configureSystemdResolved {
	if [[ $(systemctl status systemd-resolved.service | grep " active" ) ]] ; then
		echo "systemd-resolved is working I gonna disable it!"
		sudo systemctl stop systemd-resolved.service
		sudo systemctl disable systemd-resolved.service
	fi
}
function configureResolv {
	cd $HOME
	echo "I wanna add cloud flare dns for you! I think it's better to boost your speed connection!"
	echo -en "nameserver 1.1.1.1\nnameserver 1.0.0.1\n" > resolv.conf
	echo "Creating backup from $resolvConf"
	sudo mv $resolvConf $resolvConf-bak
	echo "Moving new created file as $resolvConf"
	sudo mv ./resolv.conf $resolvConf
}
configFileExistence
configureNetworkManager
configureSystemdResolved
configureResolv

echo "Done! just a moment until the NetworkManager restarts!"
sudo systemctl restart NetworkManager.service

