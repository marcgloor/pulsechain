#!/bin/sh
find . -type f -not -path "./.*" -exec md5sum {} \; > MD5SUM
