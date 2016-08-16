#!/bin/bash

function oah_echo_debug {
	if [[ "$OAH_DEBUG_MODE" == 'true' ]]; then
		echo "$1"
	fi
}

echo ""
echo "Updating oah..."
# Global variables
#OAH_INSTALLER_SERVICE=https://openapphack.github.io/oah-installer/
#OAH_INSTALLER_SERVICE="@OAH_INSTALLER_SERVICE@"
#OAH meta data service for validated OAH environments
#OAH_ENV_META_DATA_SERVICE="@OAH_ENV_META_DATA_SERVICE@"
#OAH_VERSION=0.0.1a1
#OAH_VERSION="@OAH_VERSION@"
#OAH_DIR="$HOME/.oah"


OAH_VERSION="@OAH_VERSION@"


if [ -z "${OAH_DIR}" ]; then
	OAH_DIR="$HOME/.oah"
fi

# OS specific support (must be 'true' or 'false').
cygwin=false;
darwin=false;
solaris=false;
freebsd=false;
case "$(uname)" in
    CYGWIN*)
        cygwin=true
        ;;
    Darwin*)
        darwin=true
        ;;
    SunOS*)
        solaris=true
        ;;
    FreeBSD*)
        freebsd=true
esac

oah_platform=$(uname)
oah_bin_folder="${OAH_DIR}/bin"
oah_tmp_zip="${OAH_DIR}/tmp/res-${OAH_VERSION}.zip"
oah_stage_folder="${OAH_DIR}/tmp/stage"
oah_src_folder="${OAH_DIR}/src"

oah_echo_debug "Purge existing scripts..."
rm -rf "${oah_bin_folder}"
rm -rf "${oah_src_folder}"

oah_echo_debug "Refresh directory structure..."
mkdir -p "${OAH_DIR}/bin"
mkdir -p "${OAH_DIR}/ext"
mkdir -p "${OAH_DIR}/etc"
mkdir -p "${OAH_DIR}/src"
mkdir -p "${OAH_DIR}/data/var"
mkdir -p "${OAH_DIR}/tmp"
mkdir -p "${OAH_DIR}/data/envs"
mkdir -p "${OAH_DIR}/.envs"

# prepare candidates
OAH_CANDIDATES_CSV=$(curl -s "${OAH_INSTALLER_SERVICE}/candidates")
echo "$OAH_CANDIDATES_CSV" > "${OAH_DIR}/data/var/candidates"

# drop version token
echo "$OAH_VERSION" > "${OAH_DIR}/data/var/version"

# create candidate directories
# convert csv to array
OLD_IFS="$IFS"
IFS=","
OAH_CANDIDATES=(${OAH_CANDIDATES_CSV})
IFS="$OLD_IFS"

for candidate in "${OAH_CANDIDATES[@]}"; do
    if [[ -n "$candidate" ]]; then
        mkdir -p "${OAH_DIR}/data/.envs/${candidate}"
        oah_echo_debug "Created for ${candidate}: ${OAH_DIR}/data/.envs/${candidate}"
    fi
done

if [[ -f "${OAH_DIR}/ext/config" ]]; then
	oah_echo_debug "Removing config from ext folder..."
	rm -v "${OAH_DIR}/ext/config"
fi

oah_echo_debug "Prime the config file..."
oah_config_file="${OAH_DIR}/etc/config"
touch "${oah_config_file}"
if [[ -z $(cat ${oah_config_file} | grep 'oah_auto_answer') ]]; then
	echo "oah_auto_answer=false" >> "${oah_config_file}"
fi

if [[ -z $(cat ${oah_config_file} | grep 'oah_auto_selfupdate') ]]; then
	echo "oah_auto_selfupdate=false" >> "${oah_config_file}"
fi

if [[ -z $(cat ${oah_config_file} | grep 'oah_insecure_ssl') ]]; then
	echo "oah_insecure_ssl=false" >> "${oah_config_file}"
fi

oah_echo_debug "Download new scripts to: ${oah_tmp_zip}"
#https://github.com/oah/oah/raw/gh-pages/
curl -s "${OAH_INSTALLER_SERVICE}/res/selfupdate/oah-scripts.zip" > "${oah_tmp_zip}"

oah_echo_debug "Extract script archive..."
oah_echo_debug "Unziping scripts to: ${oah_stage_folder}"
if [[ "${cygwin}" == 'true' ]]; then
	oah_echo_debug "Cygwin detected - normalizing paths for unzip..."
	unzip -qo $(cygpath -w "${oah_tmp_zip}") -d $(cygpath -w "${oah_stage_folder}")
else
	unzip -qo "${oah_tmp_zip}" -d "${oah_stage_folder}"
fi

oah_echo_debug "Moving oah-init file to bin folder..."
mv "${oah_stage_folder}/oah-init.sh" "${oah_bin_folder}"

oah_echo_debug "Move remaining module scripts to src folder: ${oah_src_folder}"
mv "${oah_stage_folder}"/oah-* "${oah_src_folder}"

oah_echo_debug "Clean up staging folder..."
rm -rf "${oah_stage_folder}"

echo ""
echo ""
echo "Successfully upgraded OAH shell."
echo ""
echo "Please open a new terminal, or run the following in the existing one:"
echo ""
echo "    source \"${OAH_DIR}/bin/oah-init.sh\""
echo ""
echo ""
