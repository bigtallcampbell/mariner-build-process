#!/bin/bash

#RUN ME on ARM64 Hardware!
CPU_ARCH=$(uname -m)
if [$CPU_ARCH -ne "aarch64"]; then
    echo "Build script must run on ARM64 hardware.  Please rerun"
    exit 1
fi

sudo apt -y install make tar wget curl rpm qemu-utils genisoimage bison gawk pigz

if ! [ -f "/usr/bin/go" ];then
    #Go isn't installed.  Go installed it
    sudo add-apt-repository ppa:longsleep/golang-backports
    sudo apt-get update
    golang-1.15-go
    sudo ln -vsf /usr/lib/go-1.15/bin/go /usr/bin/go    
fi

if ! [ -d "CBL-Mariner" ]; then
    #CBL-Mariner isn't cloned.  Grab it
    git clone https://github.com/microsoft/CBL-Mariner.git    
fi

if ! [ -d "CBL-MarinerDemo" ]; then
    #CBL-MarinerDemo isn't cloned.  Grab it
    git clone https://github.com/microsoft/CBL-MarinerDemo.git
fi

mkdir -p /mariner-arm64

#Build the toolkit
pushd CBL-Mariner/toolkit
git checkout 1.0-stable
#Clean the output just in case
sudo make clean

#Go go gadget toolkit
sudo make package-toolkit REBUILD_TOOLS=y
popd


pushd CBL-MarinerDemo
#Copy the toolkit from Mariner and extract it here
cp ../CBL-Mariner/out/toolkit-*.tar.gz ./
tar -xzvf toolkit-*.tar.gz
popd


pushd CBL-MarinerDemo/toolkit
#Go make an iso out of the default demo_iso
sudo make clean
sudo make iso CONFIG_FILE=../imageconfigs/demo_iso.json UNATTENDED_INSTALLER=y
popd

#Tar up the results
pushd CBL-MarinerDemo/out/images
tar -czvf ../../mariner-arm64/mariner-arm64.tar.gz ./* 
popd