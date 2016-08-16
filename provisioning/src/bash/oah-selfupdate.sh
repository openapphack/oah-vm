#!/bin/bash


function __oah_selfupdate {
    OAH_FORCE_SELFUPDATE="$1"
	if [[ "$OAH_AVAILABLE" == "false" ]]; then
		echo "$OFFLINE_MESSAGE"

	elif [[ "$OAH_REMOTE_VERSION" == "$OAH_VERSION" && "$OAH_FORCE_SELFUPDATE" != "force" ]]; then
		echo "No update available at this time."

	else
		curl -s "${OAH_SERVICE}/selfupdate" | bash
	fi
	unset OAH_FORCE_SELFUPDATE
}

function __oah_auto_update {

    local OAH_REMOTE_VERSION="$1"
    local OAH_VERSION="$2"

    OAH_DELAY_UPGRADE="${OAH_DIR}/var/delay_upgrade"

    if [[ -n "$(find "$OAH_DELAY_UPGRADE" -mtime +1)" && ( "$OAH_REMOTE_VERSION" != "$OAH_VERSION" ) ]]; then
        echo ""
        echo ""
        echo "ATTENTION: A new version of OAH is available..."
        echo ""
        echo "The current version is $OAH_REMOTE_VERSION, but you have $OAH_VERSION."
        echo ""

        if [[ "$oah_auto_selfupdate" != "true" ]]; then
            echo -n "Would you like to upgrade now? (Y/n)"
            read upgrade
        fi

        if [[ -z "$upgrade" ]]; then upgrade="Y"; fi

        if [[ "$upgrade" == "Y" || "$upgrade" == "y" ]]; then
            __oah_selfupdate
            unset upgrade
        else
            echo "Not upgrading today..."
        fi

        touch "${OAH_DELAY_UPGRADE}"
    fi

}
