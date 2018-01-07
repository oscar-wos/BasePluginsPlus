#!/bin/bash
DIRECTORY="/home/oscar/Git/BasePluginsPlus/"

git -C $DIRECTORY add --all
git -C $DIRECTORY commit -a
git -C $DIRECTORY push
