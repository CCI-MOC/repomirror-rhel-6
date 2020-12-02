#!/bin/sh

REPODIR="/srv/repos"
LOCKFILE="$REPODIR/.lock"

(

	echo "attempting to acquire lock"
	if ! lockfile -r0 $LOCKFILE; then
		echo "ERROR: failed to acquire lock" >&2
		exit 1
	fi

	trap "echo 'releasing lock'; rm -f $LOCKFILE" EXIT

	echo "starting reposync"
	/usr/bin/reposync \
		-p $REPODIR --quiet \
		--delete --downloadcomps --download-metadata

	if [[ $? -eq 0 ]]; then
		echo "reposync completed"
	else
		echo "reposync failed"
	fi

) 2>&1 | logger -i -t reposync-daily -p user.info
