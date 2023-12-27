#!/bin/sh
#git add --all .
git add --all -- :!/.git
./.ChangeLog.sh
./.md5sum.sh
git commit -a -m 'latest changes incorporated. Pool commit (misc).'
git push
