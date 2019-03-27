#! /bin/bash
# Author: Jack Miner <3ch01c@gmail.com>
# Description: Create a 2048-bit RSA key suitable for using with ssh or 
# other PKI tools. Two files are generated: a private key (e.g., 3ch01c)
# and a public key (e.g., 3ch01c.pub). Why 2048 bits? 
# https://danielpocock.com/rsa-key-sizes-2048-or-4096-bits
# Usage: ./ssh-keygen.sh 3ch01c

name=$1
ssh-keygen -t rsa -b 2048 -C $(basename $name) -f $name
