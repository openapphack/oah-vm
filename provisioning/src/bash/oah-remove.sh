#!/bin/bash

function __oah_remove {

OAH_PROVISIONING_DIR="${OAH_DIR}/data/env/${OAH_CURRENT_CANDIDATE}/provisioning"
ansible-playbook -i ${OAH_PROVISIONING_DIR}/inventory ${OAH_PROVISIONING_DIR}/ove-remove.yml

}
