GRUB Selector
===========
A small command-line tool that helps you to select a different kernel / grub option to boot on your Ubuntu system.

Inspired by question [Set “older” kernel as default grub entry](http://askubuntu.com/questions/216398/set-older-kernel-as-default-grub-entry) on askubuntu.com

I found it's a bit unfriendly to do this manually (especially when you are running without a desktop environment), you will have to grep menuentry from grub.cfg and copy-paste the title or count the index, then change the GRUB_DEFAULT. 

## Usage
Just download the script, and run it:

    $ /bin/bash grub_selector.sh
    Available menuentries:
    0 Ubuntu
    - Advanced options for Ubuntu
    2 Ubuntu, with Linux 4.4.0-62-generic
    3 Ubuntu, with Linux 4.4.0-62-generic (upstart)
    4 Ubuntu, with Linux 4.4.0-62-generic (recovery mode)
    5 Ubuntu, with Linux 4.4.0-31-generic
    6 Ubuntu, with Linux 4.4.0-31-generic (upstart)
    7 Ubuntu, with Linux 4.4.0-31-generic (recovery mode)
    8 Memory test (memtest86+)
    9 Memory test (memtest86+, serial console 115200)
    Please select the desired one [0-9]:

You will see a list of available options, enter the index listed here for your desired option to boot. It will double confirm the option with you.

    Please select the desired one [0-9]: 5
    Selected: "Advanced options for Ubuntu>Ubuntu, with Linux 4.4.0-31-generic"
    =========================================
    The following operation needs root access
    It will first backup /etc/default/grub
    And change the GRUB_DEFAULT in that file
    =========================================
    I understand the risk (y/N): 

And ask you to proceed with root access, as it needs to modify the /etc/default/grub file. Please reboot your system after it's done.

## References

 - [Set “older” kernel as default grub entry](http://askubuntu.com/questions/216398/set-older-kernel-as-default-grub-entry)
 - [Extract string from brackets](http://stackoverflow.com/questions/7209629/extract-string-from-brackets)
 - [Split bash string by newline characters](http://stackoverflow.com/questions/19771965/split-bash-string-by-newline-characters)
 - [How do I test if a variable is a number in bash?](http://stackoverflow.com/questions/806906/how-do-i-test-if-a-variable-is-a-number-in-bash)

## License
GPLv3

