#!/usr/bin/env bash

if ps -p $$ -o comm= | grep -q zsh; then
    RC_FILE="$HOME/.zshrc"
elif ps -p $$ -o comm= | grep -q bash; then
    RC_FILE="$HOME/.bashrc"
else
    RC_FILE="$HOME/.profile"
fi

echo $RC_FILE