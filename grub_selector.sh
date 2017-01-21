#!/bin/bash
# A small script to help you to boot into a different kernel on your system.
#
# Known issue: it does not handle multiple submenus in grub
#
# Author: Po-Hsu Lin <po-hsu.lin@canonical.com>
#

grubcfg="/boot/grub/grub.cfg"
grubfile="/etc/default/grub"
end_pattern="### END /etc/grub.d/10_linux ###"

# Find menuentries and submenu, unify the quote and extract the title
output=`grep -e 'menuentry ' -e 'submenu ' "$grubcfg" |sed "s/'/\"/g" | cut -d '"' -f2`
# Get the line index of submenu
subidx=`grep -e "menuentry " -e "submenu " "$grubcfg" | grep -n 'submenu ' | awk -F':' '{print $1}'`
# As grep -n return 1-based number, -1 for 0-based
subidx=$((subidx-1))
# The submenu will eventually ends before "### END /etc/grub.d/10_linux ###"
endidx=`grep -e "menuentry " -e "submenu " -e "$end_pattern" "$grubcfg" | grep -n "$end_pattern" | awk -F':' '{print $1}'`
endidx=$((endidx-1))

# Split results into array
IFS=' '
readarray -t entries <<<"$output"

idx=0
echo "Available menuentries:"
for entry in "${entries[@]}"
do
    if [ $idx -eq $subidx ]; then
        echo "-" $entry
    else
        echo "$idx" $entry
    fi
    idx=$((idx+1))
done
idx=$((idx-1))

read -p "Please select the desired one [0-$idx]: " opt
# Check option availability
if [ "$opt" -eq "$opt" ] 2>/dev/null ; then
    if [ $opt -gt $idx ];then
        echo "ERROR: index out of range."
        exit 1
    elif [ $opt -eq $subidx ]; then
        echo "ERROR: This is a submenu, please select other options"
        exit 1
    fi
else
    echo "ERROR: please enter number from 0 - $idx"
    exit 1
fi

if [ $opt -gt $subidx ] && [ $opt -lt $endidx ]; then
    target="\"${entries[$subidx]}>${entries[$opt]}\""
else
    target="\"${entries[$opt]}\""
fi
echo "Selected: $target"
echo "========================================="
echo "The following operation needs root access"
echo "It will first backup $grubfile"
echo "And change the GRUB_DEFAULT in that file"
echo "========================================="
read -p "I understand the risk (y/N): " ans

case $ans in
    "Y" | "y")
        echo "Backing up your grub file to ./grub-bak"
        cp "$grubfile" ./grub-bak
        echo "Modifying GRUB_DEFAULT in $grubfile"
        sudo sed -i "s/GRUB_DEFAULT=.*/GRUB_DEFAULT=$target/" "$grubfile"
        sudo update-grub
        echo "Job done, please reboot now."
        ;;
    *)
        echo "User aborted."
        ;;
esac
