#!/bin/bash

function __oah_download {
	CANDIDATE="$1"
	VERSION="${2:=master}"
	mkdir -p "${OAH_DIR}/archives"
	if [ ! -f "${OAH_DIR}/archives/${CANDIDATE}-${VERSION}.zip" ]; then
		echo ""
		echo "Downloading: ${CANDIDATE} ${VERSION}"
		echo ""
		DOWNLOAD_URL="${OAH_SERVICE}/download/${CANDIDATE}/${VERSION}/platform/${OAH_PLATFORM}/oahvm-${VERSION}.zip"
		ZIP_ARCHIVE="${OAH_DIR}/archives/${CANDIDATE}-${VERSION}.zip"
		if [[ "$oah_insecure_ssl" == "true" ]]; then
			curl -k -L "${DOWNLOAD_URL}" > "${ZIP_ARCHIVE}"
		else
			curl -L "${DOWNLOAD_URL}" > "${ZIP_ARCHIVE}"
		fi
		__oah_validate_zip "${ZIP_ARCHIVE}" || return 1
	else
		echo ""
		echo "Found a previously downloaded ${CANDIDATE} ${VERSION} archive. Not downloading it again..."
		__oah_validate_zip "${OAH_DIR}/archives/${CANDIDATE}-${VERSION}.zip" || return 1
	fi
	echo ""
}

function __oah_validate_zip {
	ZIP_ARCHIVE="$1"
	ZIP_OK=$(unzip -t "${ZIP_ARCHIVE}" | grep 'No errors detected in compressed data')
	if [ -z "${ZIP_OK}" ]; then
		rm "${ZIP_ARCHIVE}"
		echo ""
		echo "Stop! The archive was corrupt and has been removed! Please try installing again."
		return 1
	fi
}

function __oah_install {
	CANDIDATE="$1"
	LOCAL_FOLDER="$3"
	__oah_check_candidate_present "${CANDIDATE}" || return 1
	__oah_determine_version "$2" "$3" || return 1

	if [[ -d "${OAH_DIR}/data/.envs/${CANDIDATE}/${VERSION}" || -h "${OAH_DIR}/data/.envs/${CANDIDATE}/${VERSION}" ]]; then
		echo ""
		echo "Stop! ${CANDIDATE} ${VERSION} is already installed."
		return 0
	fi

	if [[ ${VERSION_VALID} == 'valid' ]]; then
		__oah_install_candidate_version "${CANDIDATE}" "${VERSION}" || return 1

		if [[ "${oah_auto_answer}" != 'true' ]]; then
			echo -n "Do you want ${CANDIDATE} ${VERSION} to be set as default? (Y/n): "
			read USE
		fi
		if [[ -z "${USE}" || "${USE}" == "y" || "${USE}" == "Y" ]]; then
			echo ""
			echo "Setting ${CANDIDATE} ${VERSION} as default."
			__oah_link_candidate_version "${CANDIDATE}" "${VERSION}"
		fi
		return 0

	elif [[ "${VERSION_VALID}" == 'invalid' && -n "${LOCAL_FOLDER}" ]]; then
		__oah_install_local_version "${CANDIDATE}" "${VERSION}" "${LOCAL_FOLDER}" || return 1

    else
        echo ""
		echo "Stop! $1 is not a valid ${CANDIDATE} version."
		return 1
	fi
}


function __oah_install_local_version {
	CANDIDATE="$1"
	VERSION="${2:=master}"
	LOCAL_FOLDER="$3"
	CANDIDATE_ENV_LOCATION="${OAH_DIR}/.envs/${CANDIDATE}"
	mkdir -p "${CANDIDATE_ENV_LOCATION}"

	echo "Linking ${CANDIDATE} ${VERSION} to ${LOCAL_FOLDER}"
	ln -s "${LOCAL_FOLDER}" "${OAH_DIR}/.envs/${CANDIDATE}/${VERSION}"
	echo "Done installing!"
	echo ""
}


function __oah_install_candidate_version {
	CANDIDATE="$1"
	# version defaults to master if no tag is giving
	VERSION="${2:=master}"

	OAH_GIT_URL="http://github.com/openapphack/"
	CANDIDATE_GIT_REPO_URL="${3:="http://github.com/openapphack/"}"
	echo "Installing: ${CANDIDATE} ${VERSION}"

  CANDIDATE_ENV_LOCATION="${OAH_DIR}/.envs/${CANDIDATE}/${VERSION}"
	CANDIDATE_ENV_LOCATION_CURRENT="${OAH_DIR}/.envs/${CANDIDATE}/current"
	ENV_LOCATION="${OAH_DIR}/env"

	mkdir -p "${CANDIDATE_ENV_LOCATION}"
  pushd .
	cd "${CANDIDATE_ENV_LOCATION}"

  echo "git clone ${CANDIDATE_GIT_REPO_URL}${CANDIDATE}.git"

	git clone ${CANDIDATE_GIT_REPO_URL}${CANDIDATE}.git

	#TODO check for valid tag before checkout of TAG

	if [[ -z "${VERSION}" || "${VERSION}" != "master" ]]; then
		echo "git checkout "tags/${VERSION}""
		git checkout "tags/${VERSION}"
  fi

	# Change the 'ENV' symlink , hence affecting all shells.
	if [ -L "${ENV_LOCATION}" ]; then
		unlink "${ENV_LOCATION}"
	fi


	# Change the 'current candidate ENV' symlink , hence affecting all shells.
	if [ -L "${CANDIDATE_ENV_LOCATION_CURRENT}" ]; then
		unlink "${CANDIDATE_ENV_LOCATION_CURRENT}"
	fi

	ln -s "${CANDIDATE_ENV_LOCATION_CURRENT}" "${CANDIDATE_ENV_LOCATION}"

	ln -s "${ENV_LOCATION}" "${CANDIDATE_ENV_LOCATION_CURRENT}"

	popd

	echo "Done installing!"
	echo ""
}
