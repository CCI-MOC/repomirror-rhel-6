#!/bin/sh

src=rhel-server-6.10-update-11-x86_64-kvm.qcow2
dst=rhel-6-repomirror-root.qcow2
dst_size=20g

if ! [[ -f $src ]]; then
	echo "ERROR: missing source image $src" >&2
	exit 1
fi

if ! [[ -f $dst ]]; then
	echo "Creating boot image..."
	qemu-img create -b $src -F qcow2 -f qcow2 $dst $dst_size
fi

virt-customize -a $dst --run customize.sh --root-password file:.rootpassword --selinux-relabel
