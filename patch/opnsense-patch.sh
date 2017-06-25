# Copyright (c) 2016-2017 Franco Fichtner <franco@opnsense.org>
INSECURE=
while getopts a:c:ip:r:s: OPT; do
	i)
		INSECURE="--no-verify-peer"
		;;
shift $((${OPTIND} - 1))
	fetch ${INSECURE} -q \
	    "${SITE}/${ACCOUNT}/${REPOSITORY}/commit/${ARG}.patch" \
	cat "${WORKDIR}/${ARG}.patch" | while read PATCHLINE; do
		case "${PATCHLINE}" in
		"diff --git a/src/"*" b/src/"*)
			OLDFILE="${PREFIX}/$(echo "${PATCHLINE}" | awk '{print $3 }' | cut -c 7-)"
			NEWFILE="${PREFIX}/$(echo "${PATCHLINE}" | awk '{print $4 }' | cut -c 7-)"
			;;
		"deleted file mode "*)
			PATCHMODE=$(echo "${PATCHLINE}" | awk '{print $4 }' | cut -c 4-6)
			if [ "${PATCHMODE}" = "644" -o "${PATCHMODE}" = "755" ]; then
				if [ -f "${OLDFILE}" ]; then
					chmod ${PATCHMODE} "${OLDFILE}"
				fi
			fi
			;;
		"new file mode "*)
			PATCHMODE=$(echo "${PATCHLINE}" | awk '{print $4 }' | cut -c 4-6)
			if [ "${PATCHMODE}" = "644" -o "${PATCHMODE}" = "755" ]; then
				if [ -f "${NEWFILE}" ]; then
					chmod ${PATCHMODE} "${NEWFILE}"
				fi
			fi
			;;
		"index "*|"new mode "*)
			# we can't figure out if we are new or old, thus no "old mode " handling
			PATCHMODE=$(echo "${PATCHLINE}" | awk '{print $3 }' | cut -c 4-6)
			if [ "${PATCHMODE}" = "644" -o "${PATCHMODE}" = "755" ]; then
				if [ -f "${NEWFILE}" ]; then
					chmod ${PATCHMODE} "${NEWFILE}"
				fi
			fi
			;;
		esac
	done