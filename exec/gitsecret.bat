@echo off
IF "%1"=="addperson" (
    cat %2 | docker run --rm -i -v %cd%:/usr/repo git-secret bash -c "gpg --import && git secret tell %3"
) ELSE (
    docker run --rm -it -v %cd%:/usr/repo git-secret git secret %*
)