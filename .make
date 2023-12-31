#!/bin/sh
git add --all -- :!/.git
git --no-pager log --format="%ai %aN %n%n%x09* %s%d%n" > ChangeLog
./.md5sum.sh
git commit -a -m 'latest changes incorporated. Pool commit (misc).'
git push
