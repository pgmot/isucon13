 #!/bin/bash
 # Usage: deploy.sh [BRANCH]
 # 
 # Arguments
 #   BRANCH  branch name. default is "master"
 
 set -eux
 set -o pipefail
 
 APP="isupipe"
 LANG="go"
 SERVICE="$APP-$LANG.service"
 ISU1="ip-192-168-0-11"
 ISU2="ip-192-168-0-13"
 ISU3="ip-192-168-0-12"
 DEFAULT_BRANCH="master"
 
 #### ARGS
 branch="${1:-"$DEFAULT_BRANCH"}"
 
 #### PREPARE
 cd "$(dirname "$0")"
 git fetch
 git reset --hard "origin/$branch"
 # git rebase "origin/$1"
 
 #### STOP
 sudo systemctl stop "${SERVICE}"
 
 case "$(hostname)" in
 "$ISU1")
     ;;
 "$ISU2")
     # sudo systemctl stop nginx
     ;;
 "$ISU3")
     ;;
 esac
 
 #### AFTER STOP
 [ -f "/var/log/nginx/access.log" ] && sudo mv /var/log/nginx/access.log /var/log/nginx/access.log.`date "+%Y%m%d_%H%M%S"`
 [ -f "/var/log/nginx/error.log" ] && sudo mv /var/log/nginx/error.log /var/log/nginx/error.log.`date "+%Y%m%d_%H%M%S"`
 [ -f "/var/log/mysql/slow_query.log" ] && sudo mv /var/log/mysql/slow_query.log /var/log/mysql/slow_query.log.`date "+%Y%m%d_%H%M%S"`
 
 # [ "`hostname`" = "$ISU1" ] && sudo systemctl restart mariadb
 
 #### BUILD
 cd $LANG
 # ./setup.sh
 make build
 
 #### START
 sudo systemctl start "${SERVICE}"
 
 case "$(hostname)" in
 "$ISU1")
     ;;
 "$ISU2")
     # sudo systemctl s nginx
     # sudo systemctl restart openresty
     ;;
 "$ISU3")
     ;;
 esac
    
