#!/usr/bin/env bash

CURRENT_FOLDER="$(cd "$(dirname "$0")" && pwd)"
echo $CURRENT_FOLDER


# FOR MY MAC
/usr/bin/grep -qxF "export PATH=\"$CURRENT_FOLDER:\$PATH\"" ~/.zshrc || \
echo "export PATH=\"$CURRENT_FOLDER:\$PATH\"" >> ~/.zshrc
/usr/bin/grep -qxF "export TOOLBOX_FOLD=\"$CURRENT_FOLDER\"" ~/.zshrc || \
echo "export TOOLBOX_FOLD=\"$CURRENT_FOLDER\"" >> ~/.zshrc
source ~/.zshrc;

# FOR A LINUX SERVER
# grep -qxF "export PATH=\"$CURRENT_FOLDER:\$PATH\"" ~/.bashrc || \
# echo "export PATH=\"$CURRENT_FOLDER:\$PATH\"" >> ~/.bashrc
# grep -qxF "export TOOLBOX_FOLD=\"$CURRENT_FOLDER\"" ~/.bashrc || \
# echo "export TOOLBOX_FOLD=\"$CURRENT_FOLDER\"" >> ~/.bashrc
# source ~/.bashrc;

chmod +x $CURRENT_FOLDER/*.sh


