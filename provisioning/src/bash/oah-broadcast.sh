#!/bin/bash


function __oah_broadcast {
	if [ "${BROADCAST_OLD_TEXT}" ]; then
		echo "${BROADCAST_OLD_TEXT}"
	else
		echo "${BROADCAST_LIVE_TEXT}"
	fi
}

function oah_update_broadcast_or_force_offline {
    BROADCAST_LIVE_ID=$(oah_infer_broadcast_id)

    oah_force_offline_on_proxy "$BROADCAST_LIVE_ID"
    if [[ "$OAH_FORCE_OFFLINE" == 'true' ]]; then BROADCAST_LIVE_ID=""; fi

    oah_display_online_availability
    oah_determine_offline "$BROADCAST_LIVE_ID"

	apptool_update_broadcast "$COMMAND" "$BROADCAST_LIVE_ID"
}

function oah_infer_broadcast_id {
	if [[ "$OAH_FORCE_OFFLINE" == "true" || ( "$COMMAND" == "offline" && "$QUALIFIER" == "enable" ) ]]; then
		echo ""
	else
		echo $(curl -s "${OAH_BROADCAST_SERVICE}/broadcast/latest/id")
	fi
}

function oah_display_online_availability {
	if [[ -z "$BROADCAST_LIVE_ID" && "$OAH_ONLINE" == "true" && "$COMMAND" != "offline" ]]; then
		echo "$OFFLINE_BROADCAST"
	fi

	if [[ -n "$BROADCAST_LIVE_ID" && "$OAH_ONLINE" == "false" ]]; then
		echo "$ONLINE_BROADCAST"
	fi
}

function apptool_update_broadcast {
	local command="$1"
	local broadcast_live_id="$2"

	local broadcast_id_file="${OAH_DIR}/data/var/broadcast_id"
	local broadcast_text_file="${OAH_DIR}/data/var/broadcast"

	local broadcast_old_id=""

	if [[ -f "$broadcast_id_file" ]]; then
		broadcast_old_id=$(cat "$broadcast_id_file");
	fi

	if [[ -f "$broadcast_text_file" ]]; then
		BROADCAST_OLD_TEXT=$(cat "$broadcast_text_file");
	fi

	if [[ "${OAH_AVAILABLE}" == "true" && "$broadcast_live_id" != "${broadcast_old_id}" && "$command" != "selfupdate" && "$command" != "flush" ]]; then
		mkdir -p "${OAH_DIR}/data/var"

		echo "${broadcast_live_id}" > "$broadcast_id_file"

		BROADCAST_LIVE_TEXT=$(curl -s "${OAH_BROADCAST_SERVICE}/broadcast/latest")
		echo "${BROADCAST_LIVE_TEXT}" > "${broadcast_text_file}"
		echo "${BROADCAST_LIVE_TEXT}"
	fi
}
