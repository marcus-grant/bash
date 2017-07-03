#!/bin/bash

dotfilePath=$(pwd)
realConfigPath=$dotfilePath/.bashrc
homePath=$HOME
linkPath=$homePath/.bashrc
profileLinkPath=$homePath/.bash_profile
profilePath=$dotfilePath/.bash_profile

echo "Preparing environment for BASH configuration."
echo "Checking if previous .bashrc exists."

if [ -f $linkPath ]; then
	echo "Previous bash file exists, backing it up with .bak suffix"
	mv $linkPath $linkPath.bak
fi

if [ -L $linkPath ]; then
	echo "Previous symlink exists, removing it."
	rm $linkPath
fi

if [ -f $profileLinkPath ]; then
    echo "Previous bash_profile exists, removing it."
    rm $profileLinkPath
fi

if [ -f $profileLinkPath ]; then
    echo "Previous bash_profile symlink exists, removing it."
    rm $profileLinkPath
fi


echo "Creating symlink for .bashrc"
echo "$linkPath -> $realConfigPath"
ln -s $realConfigPath $linkPath

echo "Creating symlink for .bash_profile"
echo "$profileLinkPath -> $profilePath"
ln -s $profilePath $profileLinkPath
echo
echo "Dotfile preperation complete!"
exit 0
