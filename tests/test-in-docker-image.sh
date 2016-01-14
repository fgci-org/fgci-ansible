#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
RDIR="$( dirname "$SOURCE" )"
SUDO=`which sudo 2> /dev/null`
SUDO_OPTION=""
#SUDO_OPTION="--sudo"
OS_TYPE=${1:-}
OS_VERSION=${2:-}
ANSIBLE_VERSION=${3:-}

ANSIBLE_VAR=""
ANSIBLE_INVENTORY="tests/inventory"
ANSIBLE_PLAYBOOk="tests/test.yml"
#ANSIBLE_LOG_LEVEL=""
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
printf "[defaults]\nroles_path = ../:roles" > ansible.cfg
printf "" > ssh.config

function show_version() {

echo "TEST: show versions"
ansible --version
id
systemctl --no-pager
proc1comm=$(cat /proc/1/comm)
echo "TEST: proc1s comm is $proc1comm"

}

function install_ansible_devel() {

# http://docs.ansible.com/ansible/intro_installation.html#latest-release-via-yum

echo "TEST: building ansible"

yum -y install PyYAML python-paramiko python-jinja2 python-httplib2 rpm-build make python2-devel asciidoc patch wget 2>&1 >/dev/null || (echo "Could not install ansible yum dependencies" && exit 2 )
rm -Rf ansible
git clone https://github.com/ansible/ansible --recursive ||(echo "Could not clone ansible from Github" && exit 2 )
cd ansible
# checking out this commit because some errors after 2015-11-05
#git checkout 07d0d2720c73816e1206882db7bc856087eb5c3f
# because systemctl and systemd
git checkout 589971fe7ef78ea8bb41fb9ae6cd19cb8e277371
make rpm 2>&1 >/dev/null
rpm -Uvh ./rpm-build/ansible-*.noarch.rpm ||(echo "Could not install built ansible devel rpms" && exit 2 )
cd ..
rm -Rf ansible

}

function install_os_deps() {
echo "TEST: installing os deps"

yum -y install epel-release sudo tree git which file less||(echo "Could not install some os deps" && exit 2 )

}

function tree_list() {

tree

}
function test_ansible_setup(){
    echo "TEST: ansible -m setup -i ${ANSIBLE_INVENTORY} --connection=local localhost"

    ansible -m setup -i ${ANSIBLE_INVENTORY} --connection=local localhost

}


function test_install_requirements(){
    echo "TEST: ansible-galaxy install -r requirements.yml --force"

    ansible-galaxy install -r requirements.yml --force ||(echo "requirements install failed" && exit 2 )

}

function test_playbook_syntax(){
    echo "TEST: ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} --syntax-check"

    ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} --syntax-check ||(echo "ansible playbook syntax check was failed" && exit 2 )
}

function test_playbook_check(){
    echo "TEST: ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} ${ANSIBLE_LOG_LEVEL} --connection=local ${SUDO_OPTION} ${ANSIBLE_EXTRA_VARS} --check"

    ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} ${ANSIBLE_LOG_LEVEL} --connection=local ${SUDO_OPTION} ${ANSIBLE_EXTRA_VARS} --check ||(echo "playbook check failed" && exit 2 )

}

function test_playbook(){
    echo "TEST: ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} ${ANSIBLE_LOG_LEVEL} --connection=local ${SUDO_OPTION} ${ANSIBLE_EXTRA_VARS}"
    ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} ${ANSIBLE_LOG_LEVEL} --connection=local ${SUDO_OPTION} ${ANSIBLE_EXTRA_VARS} ||(echo "first ansible run failed" && exit 2 )

#    echo "TEST: idempotence test! Same as previous but now grep for changed=0.*failed=0"
#    ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} ${ANSIBLE_LOG_LEVEL} --connection=local ${SUDO_OPTION} ${ANSIBLE_EXTRA_VARS} || grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' ) || (echo 'Idempotence test: fail' && exit 1)
}
function extra_tests(){

    ${APACHE_CTL} configtest || (echo "php --version was failed" && exit 100 )
}


set -e
function main(){
    install_os_deps
#    install_ansible_devel
    show_version
#    tree_list
#    test_install_requirements
    test_ansible_setup
    test_playbook_syntax
    test_playbook
    test_playbook_check
#    extra_tests

}

################ run #########################
main
