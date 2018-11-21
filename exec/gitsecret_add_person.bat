@echo off
cat %1 | docker run --rm -i -v %cd%:/usr/repo git-secret bash -c "gpg --import && git secret tell %2"