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
		echo "ERROR: reposync failed" >&2
		exit 1
	fi

	for repo in /srv/repos/*; do
		if ! [[ -d $repo/Packages ]]; then
			continue
		fi

		echo "generating repo metadata for $repo"
		if [[ -f $repo/comps.xml ]]; then
			comps="-g comps.xml"
		else
			comps=""
		fi

		createrepo --update $comps $repo
	done

	echo "all reposync operations complete"

) 2>&1 | logger -i -t reposync-daily -p user.info
