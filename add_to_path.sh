#!/usr/bin/env bash

CURRENT_FOLDER="$(cd "$(dirname "$0")" && pwd)"
echo $CURRENT_FOLDER


if ps -p $$ -o comm= | grep -q zsh; then
    RC_FILE=".zshrc"
elif ps -p $$ -o comm= | grep -q bash; then
    RC_FILE=".bashrc"
else
    RC_FILE=".profile"
fi

#RC_FILE=".zshrc"

# FOR MY MAC
# may need /usr/bin/grep
echo "Add path to $RC_FILE"
grep -qxF "export PATH=\"$CURRENT_FOLDER:\$PATH\"" $HOME/$RC_FILE|| \
echo "export PATH=\"$CURRENT_FOLDER:\$PATH\"" >> $HOME/$RC_FILE
grep -qxF "export TOOLBOX_FOLD=\"$CURRENT_FOLDER\"" $HOME/$RC_FILE || \
echo "export TOOLBOX_FOLD=\"$CURRENT_FOLDER\"" >> $HOME/$RC_FILE
source $HOME/$RC_FILE;

# FOR A LINUX SERVER
# grep -qxF "export PATH=\"$CURRENT_FOLDER:\$PATH\"" $HOME/.bashrc || \
# echo "export PATH=\"$CURRENT_FOLDER:\$PATH\"" >> $HOME/.bashrc
# grep -qxF "export TOOLBOX_FOLD=\"$CURRENT_FOLDER\"" $HOME/.bashrc || \
# echo "export TOOLBOX_FOLD=\"$CURRENT_FOLDER\"" >> $HOME/.bashrc
# source ~/.bashrc;

chmod +x $CURRENT_FOLDER/*.sh


