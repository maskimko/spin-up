#!/bin/bash
USERNAME="maskimko"
USERSHELL="/bin/bash"
USERHOME="/home/maskimko"
WILDFLYUSER="admin"
WILDFLYPASSWORD="wildfly"
WILDFLYPASSWORDHASH="1e18cb0cecd662fcf67ec0d200abe57f"
RUNSTRESSTEST="true"
export WILDFLYUSER WILDFLYPASSWORDHASH RUNSTRESSTEST

if [ -z "$(sudo grep $USERNAME /etc/passwd)" ]; then
    sudo useradd -m -d $USERHOME -s $USERSHELL -G vagrant,wheel $USERNAME
    #Password hash $6$xwEV7BT6$6xIoQ9OnxmrRsCi51ZVxvSVVEWg4/7JvcIiGILdJUQzYZbN40nrZLB.W1OHvqvhucN9NqBYPyfn46I3MGs7sx0
    sudo sed -i 's|^'$USERNAME':[^:]\+|'$USERNAME':$6$7t9lFXhx$1XMyeUxStkvrFWLohi7rqtRrBha5aXaglc..Kg6FDsqI4czD53gZ9C470fchTwrEu4Y6wYnUScm/0rYyaoZrV1|' /etc/shadow
    echo -e "\e[0;33mUser $USERNAME has been successfully created\e[0m"
else 
    echo -e "\e[0;32mUser $USERNAME has been created before\e[0m"
fi

