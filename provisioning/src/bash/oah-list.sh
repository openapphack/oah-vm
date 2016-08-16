#!/bin/bash


function __oah_build_version_csv {
	CANDIDATE="$1"
	CSV=""
	for version in $(find "${OAH_DIR}/data/.envs/${CANDIDATE}" -maxdepth 1 -mindepth 1 -exec basename '{}' \; | sort); do
		if [[ "${version}" != 'current' ]]; then
			CSV="${version},${CSV}"
		fi
	done
	CSV=${CSV%?}
}

function __oah_offline_list {
	echo "------------------------------------------------------------"
	echo "Offline Mode: only showing installed ${CANDIDATE} versions"
	echo "------------------------------------------------------------"
	echo "                                                            "

	oah_versions=($(echo ${CSV//,/ }))
	for (( i=0 ; i <= ${#oah_versions} ; i++ )); do
		if [[ -n "${oah_versions[${i}]}" ]]; then
			if [[ "${oah_versions[${i}]}" == "${CURRENT}" ]]; then
				echo -e " > ${oah_versions[${i}]}"
			else
				echo -e " * ${oah_versions[${i}]}"
			fi
		fi
	done

	if [[ -z "${oah_versions[@]}" ]]; then
		echo "   None installed!"
	fi

	echo "------------------------------------------------------------"
	echo "* - installed                                               "
	echo "> - currently in use                                        "
	echo "------------------------------------------------------------"

	unset CSV oah_versions
}

function __oah_list {
	CANDIDATE="$1"
	__oah_check_candidate_present "${CANDIDATE}" || return 1
	__oah_build_version_csv "${CANDIDATE}"
	__oah_determine_current_version "${CANDIDATE}"

	if [[ "${OAH_AVAILABLE}" == "false" ]]; then
		__oah_offline_list
	else
		FRAGMENT=$(curl -s "${OAH_SERVICE}/candidates")
		echo "${FRAGMENT}"
		unset FRAGMENT
	fi
}
