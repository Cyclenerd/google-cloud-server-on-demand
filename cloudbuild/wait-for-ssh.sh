#!/bin/bash

MY_RETRY=0
MY_MAX_RETRY=10
MY_SLEEP_SEC=30

while [ "$MY_RETRY" -le "$MY_MAX_RETRY" ]
do
	if ssh -o 'StrictHostKeyChecking=accept-new' -i '/workspace/ssh.key' "ansible@$(cat '/workspace/nat_ip.txt')" uname; then
		# Connection was successfully established
		exit 0
	fi
	echo "Retry: '$MY_RETRY', sleeping for '$MY_SLEEP_SEC' seconds..."
	sleep "$MY_SLEEP_SEC"
	MY_RETRY=$((MY_RETRY+1))
done

# No connection
exit 1