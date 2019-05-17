#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.


set -e

args=("$@")

echo "-e is........ $e"

# Exec the specified command or fall back on bash
if [ $# -eq 0 ]; then
    cmd=bash
else
    jupyter_cmd=${args[0]}
    #gpu_id=${args[1]}
    #gpu_frac=${args[2]}
    cmd=$*
    echo "jupyter_cmd = $jupyter_cmd"
    #echo "gpu_id = $gpu_id"
    #echo "gpu_frac = $gpu_frac"
fi

# Handle special flags if we're root
if [ $(id -u) == 0 ] ; then

    # Handle username change. Since this is cheap, do this unconditionally
    echo "Set username to: $NB_USER"
    usermod -d /home/$NB_USER -l $NB_USER dmig

    # handle home and working directory if the username changed
    if [[ "$NB_USER" != "dmig" ]]; then
        # changing username, make sure homedir exists
        # (it could be mounted, and we shouldn't create it if it already exists)
        if [[ ! -e "/home/$NB_USER" ]]; then
            echo "Relocating home dir to /home/$NB_USER"
            mv /home/dmig "/home/$NB_USER"
        else
            cp -RT /home/dmig/ /home/$NB_USER
        fi
        # if workdir is in /home/dmig, cd to /home/$NB_USER
        if [[ "$PWD/" == "/home/dmig/"* ]]; then
            newcwd="/home/$NB_USER/${PWD:13}"
            echo "Setting CWD to $newcwd"
            cd "$newcwd"
        fi
        # changing home directory /home/dmig to /home/$NB_USER
        export HOME=/home/$NB_USER
        fix-permissions $HOME
    fi

    # Change UID of NB_USER to NB_UID if it does not match
    if [ "$NB_UID" != $(id -u $NB_USER) ] ; then
        echo "Set $NB_USER UID to: $NB_UID"
        usermod -u $NB_UID $NB_USER
    fi

    # Change GID of NB_USER to NB_GID if it does not match
    if [ "$NB_GID" != $(id -g $NB_USER) ] ; then
        echo "Set $NB_USER GID to: $NB_GID"
        groupmod -g $NB_GID -o $(id -g -n $NB_USER)
    fi

    # Enable sudo if requested
    if [[ "$GRANT_SUDO" == "1" || "$GRANT_SUDO" == 'yes' ]]; then
        echo "Granting $NB_USER sudo access and appending $VENV_DIR/bin to sudo PATH"
        echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
        sed -ri "s#Defaults\s+secure_path=\"([^\"]+)\"#Defaults secure_path=\"\1:$VENV_DIR/bin\"#" /etc/sudoers
    fi

    # Exec the command as NB_USER with the PATH and the rest of
    # the environment preserved
    echo "Executing the command: $jupyter_cmd"
    exec sudo -E -H -u $NB_USER PATH=$PATH $jupyter_cmd
    
else
    if [[ ! -z "$NB_UID" && "$NB_UID" != "$(id -u)" ]]; then
        echo 'Container must be run as root to set $NB_UID'
    fi
    if [[ ! -z "$NB_GID" && "$NB_GID" != "$(id -g)" ]]; then
        echo 'Container must be run as root to set $NB_GID'
    fi
    if [[ "$GRANT_SUDO" == "1" || "$GRANT_SUDO" == 'yes' ]]; then
        echo 'Container must be run as root to grant sudo permissions'
    fi

    # Execute the command
    echo "Executing the command: $jupyter_cmd"
    exec $jupyter_cmd
fi
