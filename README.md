# git-secret in Docker

`Dockerfile` and instructions for running `git-secret` in `docker`.

Mainly used on Windows, to work around `git-secret` not working natively on it.

# Requirements

A private _GNU Privacy Guard_ key generated on your local system. 
Here's a guide on [Generating a new GPG key](https://help.github.com/articles/generating-a-new-gpg-key/),
if you haven't done that already.

_FYI:_ On Windows, Git Bash already contains the `gpg` command line tool.

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

> Even though the image has `gpg` included and available at runtime,
generating the `gnupg` key in a container is a difficult task.
Multiple variables come into play when
`gpg` is running `gpg-agent` and collecting random entropy,
which are linked to how the container is launched
and in what kind of environment the `docker` daemon is running.
Hence this export/import solution.

## Docker image build

If you've done the previously mentioned `gnupg` key export,
this next part is simple.
Just run the following.

```shell
docker build -t git-secret .
```

The resulting image will be used by all the other scripts, described in the **Usage** section.

# Usage

## exec

The `exec` directory contains the executable wrapper script(-s),
that let you use your newly created image in a way, similar to
how you would use `git secret <arg>` commands
if you had `git-secret` installed locally.

Just add this directory to your `PATH`, and start using them.

The following is an explanation of how these scripts work.

## gitsecret &lt;args&gt;

Execute [git-secret](http://git-secret.io/) commands in your current working directory.
```
cd /path/to/repo/with/secrets
gitsecret init
gitsecret tell <my-email>
gitsecret whoknows
# etc
```
> In a nutshell, this `gitsecret` script just mounts the current directory
to the `git-secret` container and runs the `git secret <args>` command
against it.

## gitsecret addperson &lt;public.key&gt; &lt;email&gt;

As stated in the [git-secret-tell](http://git-secret.io/git-secret-tell) documentation,
to add another user to the `git-secret` enabled repo, you will need
their public key already imported in `gpg` before `git-secret` can use it.
In this case it means that you'll first need to import the public key in the
container's `gpg`, before `git-secret` can use it.

The `gitsecret` script has been extended with the `addperson` command,
to make this importing process easier.

It requires two arguments:
* The public `gnupg` key of the person you wish to add,
which was expoerted in ascii armored form
    * `gpg --export --armor <email> > public.key`
* The email associated with said public key

```shell
gitsecret addperson /path/to/public.key other.person@example.com
```
> In a nutshell, this `gitsecret addperson` script pipes the public key
into the container, where `gpg --import` receives it. After that the 
`git secret tell <email>` command is executed.

# Known issues
* `gitsecret killperson <email>` shows a `gpg` error,
however it doesn't affect the functionality and still removes the
person from the `pubring`

# FAQ
## Why not just install `git-secret` locally?
The main reason is Windows. 
`git-secret` currently doesn't have Windows support, but this solution 
can be run on any system as long is it has `docker`, including Windows.

While this [windows support](https://github.com/sobolevn/git-secret/issues/40)
thread states that people have got it to work with `cygwin` and `WSL`,
that means that you also need one of those systems as a dependency.
This solution is aimed at people who already have `docker` and
don't want to install other dependencies.
