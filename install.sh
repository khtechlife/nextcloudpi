#!/bin/bash

# NextCloudPi installation script
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage: ./install.sh
#
# more details at https://ownyourbits.com

BRANCH="${BRANCH:-master}"
#DBG=x

set -e$DBG

TMPDIR="$(mktemp -d /tmp/nextcloudpi.XXXXXX || (echo "Failed to create temp dir. Exiting" >&2 ; exit 1) )"
trap "rm -rf \"${TMPDIR}\"" 0 1 2 3 15

[[ ${EUID} -ne 0 ]] && {
  printf "Must be run as root. Try 'sudo $0'\n"
  exit 1
}

export PATH="/usr/local/sbin:/usr/sbin:/sbin:${PATH}"

# check installed software
type mysqld &>/dev/null && echo ">>> WARNING: existing mysqld configuration will be changed <<<"
type mysqld &>/dev/null && mysql -e 'use nextcloud' &>/dev/null && { echo "The 'nextcloud' database already exists. Aborting"; exit 1; }

# get dependencies
apt-get update
apt-get install --no-install-recommends -y git ca-certificates sudo lsb-release aria2 gnupg1 libcurl3-gnutls

# get install code
if [[ "${CODE_DIR}" == "" ]]; then
  echo "Getting build code..."
  CODE_DIR="${TMPDIR}"/nextcloudpi
  git clone -b "${BRANCH}" https://github.com/DesktopECHO/nextcloudpi.git "${CODE_DIR}"
fi
cd "${CODE_DIR}"

if [ -e /usr/sbin/unchroot ]; then
	# Enable apt-fast for download reliability
	find . -type f -exec sed -i "s/apt-get install -y/apt-fast install -y/g" {} \;
	find . -type f -exec sed -i "s/apt-get install --no-install-recommends -y/apt-fast install --no-install-recommends -y/g" {} \;
	# Bypass apt-get update runs
	find . -type f -exec sed -i "s/apt-get update/echo Skipping repo fetch/g" {} \;

	# Copy SysV Init Scripts
	chmod -R 755 "${CODE_DIR}/bin"
	chmod -R 755 "${CODE_DIR}/build/linuxdeploy"
	mv ${CODE_DIR}/build/linuxdeploy/apt-fast /usr/local/bin/
	cp ${CODE_DIR}/build/linuxdeploy/* /etc/init.d/

	# Enable Init Scripts
	update-rc.d -f notify_push defaults
	update-rc.d -f nc-automount-links defaults
	update-rc.d -f nc-provisioning defaults
	update-rc.d -f ncp-metrics-exporter defaults
	update-rc.d -f nextcloud-domain defaults
	update-rc.d -f notify_push defaults
	update-rc.d -f log2ram defaults

	## PHP Update
	curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
	sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ bullseye main" > /etc/apt/sources.list.d/php.list'
	apt-get  update
fi

# install NCP
echo -e "\nInstalling NextCloudPi..."
source etc/library.sh

# check distro
check_distro etc/ncp.cfg || {
  echo "ERROR: distro not supported:";
  cat /etc/issue
  exit 1;
}

# indicate that this will be an image build
touch /.ncp-image

mkdir -p /usr/local/etc/ncp-config.d/
cp etc/ncp-config.d/nc-nextcloud.cfg /usr/local/etc/ncp-config.d/
cp etc/library.sh /usr/local/etc/
cp etc/ncp.cfg /usr/local/etc/

cp -r etc/ncp-templates /usr/local/etc/
install_app    lamp.sh
install_app    bin/ncp/CONFIG/nc-nextcloud.sh
run_app_unsafe bin/ncp/CONFIG/nc-nextcloud.sh
rm /usr/local/etc/ncp-config.d/nc-nextcloud.cfg    # armbian overlay is ro
systemctl restart mysqld # TODO this shouldn't be necessary, but somehow it's needed in Debian 9.6. Fixme
install_app    ncp.sh
run_app_unsafe bin/ncp/CONFIG/nc-init.sh
rm /.ncp-image

# skip on Armbian / Vagrant / LXD ...
[[ "${CODE_DIR}" != "" ]] || bash /usr/local/bin/ncp-provisioning.sh

## Set Country Code and bounce everything one last time ##
bash -c "cd /usr/local ; find . -type f -exec sed -i 's/echo Skipping repo fetch/apt-get update/g' {} \;"
CountryCode=$(curl -s ipinfo.io/ | jq -r .country) ; sed -i "s/$CONFIG = array (/&\n\ \ 'default_phone_region' => '$CountryCode',/" /var/www//nextcloud/config/config.php
echo Default calling region set to: $CountryCode
sed -i                   's/pm = .*/pm = static/'               /etc/php/8.1/fpm/pool.d/www.conf 
sed -i      's/pm.max_children = .*/pm.max_children = 64/'      /etc/php/8.1/fpm/pool.d/www.conf 
sed -i     's/pm.start_servers = .*/pm.start_servers = 8/'      /etc/php/8.1/fpm/pool.d/www.conf 
sed -i 's/pm.min_spare_servers = .*/pm.min_spare_servers = 8/'  /etc/php/8.1/fpm/pool.d/www.conf 
sed -i 's/pm.max_spare_servers = .*/pm.max_spare_servers = 16/' /etc/php/8.1/fpm/pool.d/www.conf 
systemctl restart dbus avahi-daemon apache2 php8.1-fpm mariadb redis-server >> /tmp/services

cd -
rm -rf "${TMPDIR}"

IP="$(get_ip)"
echo "Done.

First: Visit https://$IP/  https://nextcloudpi.local/ (also https://nextcloudpi.lan/ or https://nextcloudpi/ on windows and mac)
to activate your instance of NC, and save the auto generated passwords. You may review or reset them
anytime by using nc-admin and nc-passwd.
Second: Type 'sudo ncp-config' to further configure NCP, or access ncp-web on https://$IP:4443/
Note: You will have to add an exception, to bypass your browser warning when you
first load the activation and :4443 pages. You can run letsencrypt to get rid of
the warning if you have a (sub)domain available.
"

# License
#
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA
