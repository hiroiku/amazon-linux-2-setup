#!/bin/sh

cd `dirname $0`

git fetch &> /dev/null
git reset --hard origin/master &> /dev/null
