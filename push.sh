#!/bin/bash

msg=$1
if [ -z "${msg}" ];then
    echo "usage: push.sh msg"
    exit -1
fi

git add .
git commit -a -m "${msg}"

git push github master

git push gitcafe master:gitcafe-pages
