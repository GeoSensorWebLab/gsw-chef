#!/bin/bash
# Remotely start or stop the EC2 instance running Chef Infra Server.
# This saves a significant amount of money as the server is typically
# idle.
# 
# Run this on your development machine, and *NOT* the EC2 instance.
# Requires the AWS CLI to be installed.
set -e

print_usage () {
	echo "USAGE: remote-server-control.sh <start|stop> <INSTANCE ID>"
	echo "Instance ID can be found using 'terraform plan' and checking the 'output' section."
	exit 1
}


if [ $# -ne 2 ]; then
	print_usage
fi

case $1 in
	start)
	echo "Starting EC2 instance…"

	aws ec2 start-instances --instance-ids "$2"
	;;

	stop)
	echo "Hibernating EC2 instance."
	echo "$(tput setab 124)Note that this will disconnect any clients;\
$(tput setab 0) press control-C within 5 seconds to exit before this happens."
	sleep 6

	aws ec2 stop-instances --instance-ids "$2" --hibernate
	;;

	*)
	print_usage
	;;
esac
