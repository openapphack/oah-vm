#!/bin/bash


function __oah_cleanup_folder {
	OAH_CLEANUP_DIR="${OAH_DIR}/${1}"
	OAH_CLEANUP_DU=$(du -sh "$OAH_CLEANUP_DIR")
	OAH_CLEANUP_COUNT=$(ls -1 "$OAH_CLEANUP_DIR" | wc -l)

	rm -rf "${OAH_DIR}/${1}"
	mkdir "${OAH_DIR}/${1}"

	echo "${OAH_CLEANUP_COUNT} archive(s) flushed, freeing ${OAH_CLEANUP_DU}."

	unset OAH_CLEANUP_DIR
	unset OAH_CLEANUP_DU
	unset OAH_CLEANUP_COUNT
}

function __oah_flush {
	QUALIFIER="$1"
	case "$QUALIFIER" in
		candidates)
			if [[ -f "${OAH_DIR}/data/var/candidates" ]]; then
		        rm "${OAH_DIR}/data/var/candidates"
		        echo "Candidates have been flushed."
		    else
		        echo "No candidate list found so not flushed."
		    fi
		    ;;
		broadcast)
			if [[ -f "${OAH_DIR}/data/var/broadcast" ]]; then
		        rm "${OAH_DIR}/data/var/broadcast"
		        echo "Broadcast has been flushed."
		    else
		        echo "No prior broadcast found so not flushed."
		    fi
		    ;;
		version)
			if [[ -f "${OAH_DIR}/data/var/version" ]]; then
		        rm "${OAH_DIR}/data/var/version"
		        echo "Version Token has been flushed."
		    else
		        echo "No prior Remote Version found so not flushed."
		    fi
		    ;;
		envs)
			__oah_cleanup_folder "/data/.envs"
				;;
		archives)
			__oah_cleanup_folder "archives"
		    ;;
		temp)
			__oah_cleanup_folder "tmp"
		    ;;
		tmp)
			__oah_cleanup_folder "tmp"
		    ;;
		*)
			echo "Stop! Please specify what you want to flush."
			;;
	esac
}
