#!/bin/bash
USERNAME="maskimko"
USERSHELL="/bin/bash"
USERHOME="/home/maskimko"
if [ -z "$(sudo grep $USERNAME /etc/passwd)" ]; then
    sudo useradd -m -d $USERHOME -s $USERSHELL -G vagrant $USERNAME
    #Password hash $6$xwEV7BT6$6xIoQ9OnxmrRsCi51ZVxvSVVEWg4/7JvcIiGILdJUQzYZbN40nrZLB.W1OHvqvhucN9NqBYPyfn46I3MGs7sx0
    sudo sed -i '/^tss/ s|^'$USERNAME':[^:]\+|'$USERNAME':$6$xwEV7BT6$6xIoQ9OnxmrRsCi51ZVxvSVVEWg4/7JvcIiGILdJUQzYZbN40nrZLB.W1OHvqvhucN9NqBYPyfn46I3MGs7sx0|' /etc/shadow
    echo -e "\e[0;33mUser $USERNAME has been successfully created\e[0m"
else 
    echo -e "\e[0;32mUser $USERNAME has been created before\e[0m"
fi

