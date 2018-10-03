#!/bin/bash
#
# A script that helps you to select a different kernel to boot on your Ubuntu system.
# https://github.com/Cypresslin/grub_selector
#
#                              Author: Po-Hsu Lin <po-hsu.lin@canonical.com>

grubcfg="/boot/grub/grub.cfg"
grubfile="/etc/default/grub"
end_pattern="### END /etc/grub.d/10_linux ###"
one_time=false

function filecheck {
    if [ ! -f $1 ]; then
        echo "$1 not found, please change the setting"
        exit 1
    fi
}

# Flag parser
while [[ $# > 0 ]]
do
    flag="$1"
    shift
    case $flag in
        -y | --yes)
        echo "You won't be asked to answer the 'I understand the risk' question."
        ans="y"
        shift
        ;;
        --once)
        echo "Running in one-time task mode"
        one_time=true
        shift
        ;;
        *)
        echo "ERROR: Unknown option"
        echo "Usage: bash grub_selector.sh [options]"
        echo ""
        echo "Options:"
        echo -e "  -y | --yes\tReply YES to the 'I understand the risk' question"
        echo -e "  --once\tBoot to the desired option for next reboot only"
        exit
        ;;
    esac
done

filecheck $grubcfg
filecheck $grubfile
# Find menuentries and submenu, unify the quote and extract the title
rawdata=`grep -e 'menuentry ' -e 'submenu ' "$grubcfg"`
output=`echo "$rawdata" |sed "s/'/\"/g" | cut -d '"' -f2`
# Get the line index of submenu
subidx=`echo "$rawdata" | grep -n 'submenu ' | awk -F':' '{print $1}'`
# As grep -n return 1-based number, -1 for 0-based bash array
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
    target="'${entries[$subidx]}>${entries[$opt]}'"
else
    target="'${entries[$opt]}'"
fi
echo "Selected: $target"
echo "==========================================="
echo "The following operation needs root access"
echo "It will backup $grubfile first, and"
echo "make changes to the GRUB_DEFAULT if needed"
echo "==========================================="
if [ "$ans" == "y" ]; then
    echo "YES I understand the risk."
else
    read -p "I understand the risk (y/N): " ans
fi

case $ans in
    "Y" | "y")
        grep "^GRUB_DEFAULT=saved" $grubfile > /dev/null
        if [ $? -ne 0 ]; then
            echo "Backing up your grub file to ./grub-bak"
            cp "$grubfile" ./grub-bak
            echo "Changing GRUB_DEFAULT to 'saved' in $grubfile"
            sudo sed -i "s/GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/" $grubfile
            sudo update-grub
        fi
        if [ $one_time = true ]; then
            echo "Setting up one-time task with grub-reboot..."
            cmd="sudo grub-reboot $target"
            eval $cmd
        else
            echo "Setting up default boot option with grub-set-default..."
            cmd="sudo grub-set-default $target"
            eval $cmd
        fi
        echo "Job done, please reboot now."
        ;;
    *)
        echo "User aborted."
        ;;
esac
