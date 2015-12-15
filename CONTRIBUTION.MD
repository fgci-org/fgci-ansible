fgci-ansible contribution guidelines
-------------------------

Branches
--------

 - master: Work on master, or even better work in feature branches
 - testing: After the work is merged into master, merge it into test and run testing on it
 - production: After it's been tested and it's working on the test system, merge it to production

Pull Requests
-------------

 - Make a fork of this repo (or the ansible-role repo if it's for a role)
 - Create a new branch in your fork called "new_feature"
  - This is important, don't make the updates in the master branch of your local repo.
 - Commit and push to this new_feature branch in your repo
 - Create a pull request with the fix

Ansible Roles
-------------

These are suggestions for requirements of roles that the fgci-ansible orchestrator playbook uses.

 - **name** must start with: ansible-role-* - if it's an external role, change the name in requirements.yml
 - **meta:** there must be a meta/main.yml and should be filled in as much as possible
 - **independence:** the role should work by itself - it shouldn't depend on other roles. For example if a role installs software from a repo that is not installed by default, the repo and software should be added in that role.
 - **defaults:** if the role uses any variables, they should be defined and have defaults in defaults/main.yml
 - **idempotence:** if you run the same role twice it should not change anything on the second run
 - **readme:**  README.MD should contain description
 - **variables names:**  the variable namespace is global, so try to not use variables called "packages" or "installed". role_name_variable_name is better.
 - **automatic testing:** add the role to travis. Some files needed in the repo - For example see https://github.com/CSC-IT-Center-for-Science/ansible-role-cvmfs

CSC tasks after adding a new role/repo:
 - **enable automatic testing:** enable the repo in https://travis-ci.org/CSC-IT-Center-for-Science/
 - **notifications:** add the new github repo to the #fgci channel in flowdock
 - **backlog management:** add the new github repo to https://waffle.io/CSC-IT-Center-for-Science/fgci-ansible/

Ansible role suggestions (not mandatory):

Make it work on also non-EL systems. Don't use yum module if possible, use something like:

<pre>
- name: install rdma
  action: 
    module: "{{ ansible_pkg_mgr }}" 
    name: rdma 
    state: present
 </pre>

If the role is only for EL, have this in ansible-role-name/tasks/main.yml:

<pre>
- include: redhat.yml
  when: ansible_os_family == "RedHat"
</pre> 

Then do the tasks in redhat.yml 

command/shell tasks should be avoided, but if they are used and they are only used to write the output into a variable - they should have "always_run: True" so that the role works when running the playbook it with --check. They should also have a "changed_when: False" so that they aren't listed as changed. 


