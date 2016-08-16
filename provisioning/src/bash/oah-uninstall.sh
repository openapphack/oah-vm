#!/bin/bash


function __oah_uninstall {
	CANDIDATE="$1"
	VERSION="$2"
	__oah_check_candidate_present "${CANDIDATE}" || return 1
	__oah_check_version_present "${VERSION}" || return 1
	CURRENT=$(readlink "${OAH_DIR}/data/.envs/${CANDIDATE}/current" | sed "s_${OAH_DIR}/data/.envs/${CANDIDATE}/__g")
	if [[ -h "${OAH_DIR}/data/.envs/${CANDIDATE}/current" && ( "${VERSION}" == "${CURRENT}" ) ]]; then
		echo ""
		echo "Unselecting ${CANDIDATE} ${VERSION}..."
		unlink "${OAH_DIR}/data/.envs/${CANDIDATE}/current"
	fi
	echo ""
	if [ -d "${OAH_DIR}/data/.envs/${CANDIDATE}/${VERSION}" ]; then
		echo "Uninstalling ${CANDIDATE} ${VERSION}..."
		rm -rf "${OAH_DIR}/data/.envs/${CANDIDATE}/${VERSION}"
	else
		echo "${CANDIDATE} ${VERSION} is not installed."
	fi
}
