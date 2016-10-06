This scripts is provided to update arc toolchain version in buildroot project.
It is relevant while special ARC builds are used for ARC architecture.
When ARC begin to use upstream binutils, gdb and gcc, this script should be either
updated or never used.

# NOTE: The script is suited to update only arc toolchain
# NOTE: If scipt fails, it reverts ALL your local changes. So use it only after you have commited all your changes

Run ./BR_TC_VER -h to get info about how to use this script.

*******************************************************
 Use only after you have commited ALL your local changes!

 Usage:  ./BR_TC_VER -o [old_version] -n [new_version] -p [path_to_buildroot]

        [old_version]                   should be something like "arc-YYYY.MM"
        [new_version]                   should be something like "arc-YYYY.MM"
        [path_to_buildroot]             is path to "buildroot" root directory

 One more note should be added - after update you need to check everyhing
 manually, especially custom patches as they may not be required.

*******************************************************

--------------------------
For more information contact
Vlad Zakharov <vzakhar@synopsys.com>
