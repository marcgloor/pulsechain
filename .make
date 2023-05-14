#!/bin/sh
git add --all .
./.ChangeLog.sh
./.md5sum.sh
git commit -a -m 'latest changes incorporated. Miscellaneous'
git push
