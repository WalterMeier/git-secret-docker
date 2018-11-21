# git-secret in Docker

`Dockerfile` and instructions for running `git-secret` in `docker`.

Mainly used on Windows, to work around `git-secret` not working natively on it.

# Requirements

A private _GNU Privacy Guard_ key generated on your local system. 
Here's a guide on [Generating a new GPG key](https://help.github.com/articles/generating-a-new-gpg-key/),
if you haven't done that already.

# Getting started

## GNU Privacy Guard

You'll need to clone this repo and export your private `gnupg` key into it,
so that it can be imported during `docker build`.

```shell
git clone https://github.com/WalterMeier/git-secret-docker.git
cd git-secret-docker
gpg --export-secret-key -a <email> > private.key
```

> `private.key` is already in `.gitignore`

> Even though the container has `gpg` installed and available at runtime,
generating the `gnupg` key in a container is a difficult task.
Multiple variables come into play when
`gpg` is running `gpg-agent` and collecting random entropy,
which are linked to how the container is launched
and in what kind of environment the `docker` daemon is running.

## Docker image build

If you've done the previously mentioned `gnupg` key export,
this next part is simple.
Just run the following.

```shell
docker build -t git-secret .
```

# Usage

## git secret commands

You can manually run the `git-secret` container and mount the data in it as you see fit,
so that you can then execute the `git secret` commands against said data. 

To make it easier however, we've provided the `gitsecret` wrapper in the `exec` directory.
Just add the `exec` dir to your PATH and you can run `git secret` commands via
the `gitsecret` wrapper as follows.
```
cd /path/to/repo/you/want/to/encrypt
gitsecret init
gitsecret tell john.doe@example.com
# etc
```
> In a nutshell, this `gitsecret` wrapper just mounts the current directory
to the `git-secret` container and runs the `git secret <args>` command
against it.

## Adding other people to git-secret repo

As stated in the [git-secret-tell](http://git-secret.io/git-secret-tell) documentation,
to add another user to the `git-secret` enabled repo,
you will need their public key already imported in `gpg` before `git-secret`
can use it.
In this case it means that you'll first need to import the public key in the
container's `gpg`, before `git-secret` can use it.

To make this importing process easier, we've provided the `gitsecret_add_person`
wrapper that will do most of the heavy lifting.
You'll only need to provide the public key file path on your local machine,
and the email that the key was generated with (the email of the key's owner).
**Both arguments are required**

```shell
gitsecret_add_person /path/to/public.key other.dev@example.com
```
> In a nutshell, this `gitsecret_add_person` wrapper pipes the public key
into the container, where `gpg --import` receives it. After that the 
`git secret tell <email>` command is executed.

# Known issues
* `gitsecret killperson <email>` shows a `gpg` error,
however it doesn't affect the functionality and still removes the
person from the `pubring`

# FAQ
* Why not just install `git-secret` locally?
    * The main reason is Windows. 
    `git-secret` currently doesn't have Windows support, but this solution 
    can be run on any system as long is it has `docker`, including Windows.