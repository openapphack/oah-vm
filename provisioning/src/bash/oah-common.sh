#!/bin/bash

#
# common internal function definitions
#

function __oah_check_candidate_present {
	if [ -z "$1" ]; then
		echo -e "\nNo candidate provided."
		__oah_help
		return 1
	fi
}

function __oah_check_version_present {
	if [ -z "$1" ]; then
		echo -e "\nNo candidate version provided."
		__oah_help
		return 1
	fi
}

function __oah_determine_version {

	if [[ "${OAH_AVAILABLE}" == "false" && -n "$1" && -d "${OAH_DIR}/data/.envs/${CANDIDATE}/$1" ]]; then
		VERSION="$1"

	elif [[ "${OAH_AVAILABLE}" == "false" && -z "$1" && -L "${OAH_DIR}/data/.envs/${CANDIDATE}/current" ]]; then

		VERSION=$(readlink "${OAH_DIR}/data/.envs/${CANDIDATE}/current" | sed "s!${OAH_DIR}/data/.envs/${CANDIDATE}/!!g")

	elif [[ "${OAH_AVAILABLE}" == "false" && -n "$1" ]]; then
		echo "Stop! ${CANDIDATE} ${1} is not available in offline mode."
		return 1

	elif [[ "${OAH_AVAILABLE}" == "false" && -z "$1" ]]; then
        echo "${OFFLINE_MESSAGE}"
        return 1

	elif [[ "${OAH_AVAILABLE}" == "true" && -z "$1" ]]; then
		VERSION_VALID='valid'
		VERSION=$(curl -s "${OAH_SERVICE}/candidates/${CANDIDATE}/default")

	else
		VERSION_VALID=$(curl -s "${OAH_SERVICE}/candidates/${CANDIDATE}/$1")
		if [[ "${VERSION_VALID}" == 'valid' || ( "${VERSION_VALID}" == 'invalid' && -n "$2" ) ]]; then
			VERSION="$1"

		elif [[ "${VERSION_VALID}" == 'invalid' && -h "${OAH_DIR}/data/.envs/${CANDIDATE}/$1" ]]; then
			VERSION="$1"

		elif [[ "${VERSION_VALID}" == 'invalid' && -d "${OAH_DIR}/data/.envs/${CANDIDATE}/$1" ]]; then
			VERSION="$1"

		else
			echo ""
			echo "Stop! $1 is not a valid ${CANDIDATE} version."
			return 1
		fi
	fi
}

function __oah_default_environment_variables {

	if [ ! "$OAH_FORCE_OFFLINE" ]; then
		OAH_FORCE_OFFLINE="false"
	fi

	if [ ! "$OAH_ONLINE" ]; then
		OAH_ONLINE="true"
	fi

	if [[ "${OAH_ONLINE}" == "false" || "${OAH_FORCE_OFFLINE}" == "true" ]]; then
		OAH_AVAILABLE="false"
	else
	  	OAH_AVAILABLE="true"
	fi
}

function __oah_link_candidate_version {
	CANDIDATE="$1"
	VERSION="$2"

	# Change the 'current' symlink for the candidate, hence affecting all shells.
	if [ -L "${OAH_DIR}/data/.envs/${CANDIDATE}/current" ]; then
		unlink "${OAH_DIR}/data/.envs/${CANDIDATE}/current"
	fi
	ln -s "${OAH_DIR}/data/.envs/${CANDIDATE}/${VERSION}" "${OAH_DIR}/data/.envs/${CANDIDATE}/current"
}
