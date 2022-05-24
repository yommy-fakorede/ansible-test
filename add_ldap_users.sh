#!/bin/bash

nl=`wc -l < /var/local/adm/users`
    if [ "$nl" = 0 ]; then
        printf "\n ******  /var/local/adm/users file is empty, no action performed ******\n"
    else
        printf "\n ****** Checking User in LDAP ******\n"
            for uid in `cat /var/local/adm/users| egrep -v '^#'`
                do
        getent passwd $uid
        if [ $? -eq 0 ];
        then
            printf "\n ****** $uid found in LDAP ******\n"
            mkdir -p /home/$uid
            cd /home/$uid
            mkdir -p .ssh
            cd .ssh
            touch authorized_keys
            cd /home
            cp -n /root/.bash_profile /home/$uid/
            cp -n /root/.bashrc /home/$uid
            chown -R $uid:mpulse $uid
            chmod 700 $uid/.ssh
            cd /home/$uid/.ssh
            printf "\n ****** Copying the public key from S3 bucket ****** \n"
            aws s3 cp s3://mp-keys/$uid/.ssh/ ./ --recursive
            chmod 644 /home/$uid/.ssh/authorized_keys
            printf "\n ****** User $uid is created ******\n"
                    #usermod -aG docker $uid
                        #usermod -aG airflow $uid
               else
            cd /home
                        if [ -d "/home/$uid" ]; then
                 mv /home/$uid /home/.$uid
                             printf "\n ****** User $uid home directory is removed ****** \n"
                        fi
                        printf "\n ****** User $uid is not found on LDAP ****** \n"
        fi
        done
    fi
