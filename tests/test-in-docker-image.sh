#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
RDIR="$( dirname "$SOURCE" )"
SUDO=`which sudo 2> /dev/null`
SUDO_OPTION="--sudo"
OS_TYPE=${1:-}
OS_VERSION=${2:-}
ANSIBLE_VERSION=${3:-}

ANSIBLE_VAR=""
ANSIBLE_INVENTORY="tests/inventory"
ANSIBLE_PLAYBOOk="tests/test.yml"
ANSIBLE_LOG_LEVEL="-vvv"
APACHE_CTL="apache2ctl"

# if there wasn't sudo then ansible couldn't use it
if [ "x$SUDO" == "x" ];then
    SUDO_OPTION=""
fi

if [ "${OS_TYPE}" == "centos" ];then
    APACHE_CTL="apachectl"
    if [ "${OS_VERSION}" == "7" ];then
        ANSIBLE_VAR="apache_use_service=False"
    fi
fi

ANSIBLE_EXTRA_VARS=""
if [ "${ANSIBLE_VAR}x" == "x" ];then
    ANSIBLE_EXTRA_VARS=" -e \"${ANSIBLE_VAR}\" "
fi


cd $RDIR/..
printf "[defaults]\nroles_path = ../:fgci-ansible/roles:roles" > ansible.cfg
printf "" > ssh.config

function show_version() {

ansible --version

}

function install_systemd() {
sudo yum -y install systemd

}

function tree_list() {

sudo yum -y install tree

tree

}

function test_install_requirements(){

    ansible-galaxy install -r requirements.yml --force || (echo "requirements install failed" && exit 2 )

}

function test_playbook_syntax(){

    ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} --syntax-check || (echo "ansible playbook syntax check was failed" && exit 2 )
}

function test_playbook(){
    # first run
    ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} ${ANSIBLE_LOG_LEVEL} --connection=local ${SUDO_OPTION} ${ANSIBLE_EXTRA_VARS} || ( echo "first run was failed" && exit 2 )

    # Run the role/playbook again, checking to make sure it's idempotent.
    # ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} ${ANSIBLE_LOG_LEVEL} --connection=local ${SUDO_OPTION} ${ANSIBLE_EXTRA_VARS} | grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' ) || (echo 'Idempotence test: fail' && exit 1)
}
function extra_tests(){

    ${APACHE_CTL} configtest || (echo "php --version was failed" && exit 100 )
}


set -e
function main(){
    show_version
    tree_list
    install_systemd
    test_install_requirements
    test_playbook_syntax
    test_playbook
#    extra_tests

}

################ run #########################
main