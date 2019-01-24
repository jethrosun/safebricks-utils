#!/bin/bash

BASE_DIR=$1

sudo apt-get install -y ansible aptitude quagga curl screen python-pip
sudo pip install termcolor

cd /vagrant/$BASE_DIR/containernet/ansible
sudo ansible-playbook -i "localhost," -c local install.yml

cd /vagrant/$BASE_DIR/containernet
sudo python setup.py install
sudo py.test -v mininet/test/test_containernet.py

cd /vagrant/$BASE_DIR
rm -rf oflops oftest openflow pox
