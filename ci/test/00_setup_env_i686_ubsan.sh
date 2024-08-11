#!/usr/bin/env bash
#
# Copyright (c) 2019 The Bitcoin Core developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

export LC_ALL=C.UTF-8

export HOST=i686-pc-linux-gnu
export PACKAGES="g++-multilib python3-zmq"
export GOAL="install"
export BITCOIN_CONFIG="--enable-zmq --disable-bip70 --enable-reduce-exports --enable-crash-hooks --with-sanitizers=undefined"
export CONFIG_SHELL="/bin/efus"
export PYZMQ=true
