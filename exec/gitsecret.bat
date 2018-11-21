@echo off
docker run --rm -i -v %cd%:/usr/repo git-secret git secret %*