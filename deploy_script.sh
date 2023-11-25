#!/bin/bash
set -eux
set -o pipefail

export PATH="$HOME/local/golang/bin:/home/isucon/golang/bin:$PATH"

BRANCH="${1:-"master"}"

cd "$(dirname "$0")"
if [ -d ".git" ]; then
	git fetch
	git checkout "$BRANCH"
	git reset --hard origin/"$BRANCH"
fi

sudo test -f "/var/log/nginx/access.log" && sudo mv /var/log/nginx/access.log /var/log/nginx/access.log.`date "+%Y%m%d_%H%M%S"`
sudo test -f "/var/log/nginx/error.log" && sudo mv /var/log/nginx/error.log /var/log/nginx/error.log.`date "+%Y%m%d_%H%M%S"`
sudo test -f "/var/log/mysql/mysql-slow.log" && sudo mv /var/log/mysql/mysql-slow.log /var/log/mysql/mysql-slow.log.`date "+%Y%m%d_%H%M%S"`

cd go/
make

hostname="$(hostname)"
case "${hostname}" in
	"ip-192-168-0-11") # isucon1
		sudo systemctl restart nginx
		sudo systemctl restart isupipe-go.service
        sudo systemctl restart mysql
		;;
	"ip-192-168-0-13") # isucon2
		#sudo systemctl restart mysql
		;;
	"ip-192-168-0-12") # isucon3
		#sudo systemctl restart isupipe-go.service
		;;
	*)
		echo "${hostname} Didn't match anything"
		exit 1
esac