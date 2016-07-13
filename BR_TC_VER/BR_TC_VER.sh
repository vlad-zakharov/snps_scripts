#!/bin/bash

# NOTE: The script is suited to update only arc toolchain

# Help sctring

help_str="Usage:\n\n
./BR_TC_VER -o [old_version] -n [new_version] -p [path_to_buildroot]\n\n
NOTE: -o and -p are requred options, missing them will lead to failures\n\n
\t[old_version]\t\t\tshould be something like \"arc-YYYY.MM\"\n
\t[new_version]\t\t\tshould be something like \"arc-YYYY.MM\"\n
\t[path_to_buildroot]\t\tis path to \"buildroot\" root directory\n"

# Script variables with default values
old=""                           # Required option
version="arc-2016.03"                      
buildroot_path=""                # Required option
sha_sum=none

# Get the command line parametres
while getopts ":n:p:o:h" OPTION; do
    case "$OPTION" in
	n)
	    version=$OPTARG
	    ;;
	p)
	    buildroot_path=$OPTARG
	    ;;
	o)
	    old=$OPTARG
	    ;;
	h)
	    echo -e $help_str
	    exit 1
	    ;;
	\?)
	    echo "No such argument"
	    ;;
    esac
done

if [ -z $old ];
then
    echo "You must specify old version of toolchain to run the script"
    exit 1
fi

if [ -z $buildroot_path ];
then
    echo "You must specify paht to buildroot to run the script"
    exit 1
fi



#### Update binutils ####
cd $buildroot_path/package/binutils
sed "s/$old/$version/g" Config.in.host > Config.in.host.temp
mv Config.in.host.temp Config.in.host

sed "s/$old/$version/g" binutils.mk > binutils.mk.temp
mv binutils.mk.temp binutils.mk

git mv $old $version

# Update sha hash for new binutils
if test -e "../../dl/binutils-$version.tar.gz"
then
    sha_sum=$(sha512sum "../../dl/binutils-$version.tar.gz" | awk '{print $1;}')
else
    wget -P ../../dl "https://github.com/foss-for-synopsys-dwc-arc-processors/binutils-gdb/archive/$version/binutils-$version.tar.gz"
    sha_sum=$(sha512sum "../../dl/binutils-$version.tar.gz" | awk '{print $1;}')
fi
sed "s/sha512.*binutils-${old}.tar.gz/sha512\ \ ${sha_sum}\ \ binutils-${version}.tar.gz/g" binutils.hash > binutils.hash.temp
mv binutils.hash.temp binutils.hash



#### Update gcc ####
cd $buildroot_path/package/gcc
sed "s/$old/$version/g" Config.in.host > Config.in.host.temp
mv Config.in.host.temp Config.in.host

git mv $old $version

# Update sha hash for new gcc
if test -e "../../dl/gcc-$version.tar.gz"
then
    sha_sum=$(sha512sum "../../dl/gcc-$version.tar.gz" | awk '{print $1;}')
else
    wget -P ../../dl "https://github.com/foss-for-synopsys-dwc-arc-processors/gcc/archive/$version/gcc-$version.tar.gz"
    sha_sum=$(sha512sum "../../dl/gcc-$version.tar.gz" | awk '{print $1;}')
fi
sed "s/sha512.*gcc-${old}.tar.gz/sha512\ \ ${sha_sum}\ \ gcc-${version}.tar.gz/g" gcc.hash > gcc.hash.temp
mv gcc.hash.temp gcc.hash
