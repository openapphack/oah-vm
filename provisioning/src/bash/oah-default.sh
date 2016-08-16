#!/bin/bash



function __oah_default {
	CANDIDATE="$1"
	__oah_check_candidate_present "${CANDIDATE}" || return 1
	__oah_determine_version "$2" || return 1

	if [ ! -d "${OAH_DIR}/data/.envs/${CANDIDATE}/${VERSION}" ]; then
		echo ""
		echo "Stop! ${CANDIDATE} ${VERSION} is not installed."
		return 1
	fi

	__oah_link_candidate_version "${CANDIDATE}" "${VERSION}"

	echo ""
	echo "Default ${CANDIDATE} version set to ${VERSION}"
}
