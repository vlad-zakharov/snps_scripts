#!/bin/bash

# NOTE: The script is suited to update only arc toolchain

# Help sctring

help_str=" Usage:\t
./BR_TC_VER -o [old_version] -n [new_version] -p [path_to_buildroot]\n\n
NOTE: -o and -p are requred options, missing them will lead to failures\n\n
\t[old_version]\t\t\tshould be something like \"arc-YYYY.MM\"\n
\t[new_version]\t\t\tshould be something like \"arc-YYYY.MM\"\n
\t[path_to_buildroot]\t\tis path to \"buildroot\" root directory\n\n
One more note should be added - after update you need to check everyhing\n
manually, especially custom patches as they may not be required.\n"

# Script variables with default values
old=""
version="arc-2016.03"                      
buildroot_path="$HOME/git/buildroot"
sha_sum=none

# Files where the script tries to find old arc toolchain version
search_files="binutils/Config.in.host binutils/binutils.mk binutils/binutils.hash gcc/Config.in.host gcc/gcc.hash"

function detect_version {
    for file in $search_files
    do
	old=`egrep -o "arc-[0-9]{4}\.[0-9]{2}(-eng[0-9]{3})?" $buildroot_path/package/$file`
	if [ $? -eq 0  ];
	then
	    echo "Old version detected: $old"
	    return 0;
	fi
    done
    return 1;
}

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
	    exit 0
	    ;;
	\?)
	    echo "No such argument"
	    exit 1
	    ;;
    esac
done

# Verify if buildroot directory exists
if [ ! -d $buildroot_path ]
then
    echo 1>&2 "Buidroot directory doesn't exist. Plese specify correct path to buildroot. For more info run \"./BR_TC_VER -h\" ."
    exit 1
fi

# Detect old version to be updated
detect_version
if [ $? -ne 0 ]
then
    echo 1>&2 "Version autodetection filed. Please specify old version you want to update."
    exit 1
fi

# No sense to update if old version matches with the new version. 
if [ "$old" == "$version" ]
then
    echo "Old version coinsides with new version. No sense to update"
    exit 0
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
