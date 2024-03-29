- [Supported Tags](#org270ff05)
  - [Simple Tags](#org7740dc5)
  - [Shared Tags](#org99f332f)
- [Quick Reference](#orgfe4abeb)
- [What is SBCL?](#org616c5bd)
- [How to use this image](#orge60c990)
  - [Create a `Dockerfile` in your SBCL project](#org44f646c)
  - [Run a single Common Lisp script](#org099cc26)
  - [Developing using SLIME](#orgfa276fd)
- [What's in the image?](#org3e8366b)
- [Image variants](#org47c820a)
  - [`%%IMAGE%%:<version>`](#orgf2cf1db)
  - [`%%IMAGE%%:<version>-slim`](#orgfc15c8c)
  - [`%%IMAGE%%:<version>-alpine`](#org8d4837e)
  - [`%%IMAGE%%:<version>-windowsservercore`](#org563afc8)
- [License](#orgead3ba9)



<a id="org270ff05"></a>

# Supported Tags


<a id="org7740dc5"></a>

## Simple Tags

INSERT-SIMPLE-TAGS


<a id="org99f332f"></a>

## Shared Tags

INSERT-SHARED-TAGS


<a id="orgfe4abeb"></a>

# Quick Reference

-   **SBCL Home Page:** [http://sbcl.org](http://sbcl.org)
-   **Where to file Docker image related issues:** <https://gitlab.common-lisp.net/cl-docker-images/sbcl>
-   **Where to file issues for SBCL itself:** [https://bugs.launchpad.net/sbcl](https://bugs.launchpad.net/sbcl)
-   **Maintained by:** [CL Docker Images Project](https://common-lisp.net/project/cl-docker-images)
-   **Supported platforms:** `linux/amd64`, `linux/arm64/v8`, `linux/arm/v7`, `windows/amd64`


<a id="org616c5bd"></a>

# What is SBCL?

From [SBCL's Home Page](http://sbcl.org):

> Steel Bank Common Lisp (SBCL) is a high performance Common Lisp compiler. It is open source / free software, with a permissive license. In addition to the compiler and runtime system for ANSI Common Lisp, it provides an interactive environment including a debugger, a statistical profiler, a code coverage tool, and many other extensions.


<a id="orge60c990"></a>

# How to use this image


<a id="org44f646c"></a>

## Create a `Dockerfile` in your SBCL project

```dockerfile
FROM %%IMAGE%%:latest
COPY . /usr/src/app
WORKDIR /usr/src/app
CMD [ "sbcl", "--load", "./your-daemon-or-script.lisp" ]
```

You can then build and run the Docker image:

```console
$ docker build -t my-sbcl-app
$ docker run -it --rm --name my-running-app my-sbcl-app
```


<a id="org099cc26"></a>

## Run a single Common Lisp script

For many simple, single file projects, you may find it inconvenient to write a complete \`Dockerfile\`. In such cases, you can run a Lisp script by using the SBCL Docker image directly:

```console
$ docker run -it --rm --name my-running-script -v "$PWD":/usr/src/app -w /usr/src/app %%IMAGE%%:latest sbcl --load ./your-daemon-or-script.lisp
```


<a id="orgfa276fd"></a>

## Developing using SLIME

[SLIME](https://common-lisp.net/project/slime/) provides a convenient and fun environment for hacking on Common Lisp. To develop using SLIME, first start the Swank server in a container:

```console
$ docker run -it --rm --name sbcl-slime -p 127.0.0.1:4005:4005 -v /path/to/slime:/usr/src/slime -v "$PWD":/usr/src/app -w /usr/src/app %%IMAGE%%:latest sbcl --load /usr/src/slime/swank-loader.lisp --eval '(swank-loader:init)' --eval '(swank:create-server :dont-close t :interface "0.0.0.0")'
```

Then, in an Emacs instance with slime loaded, type:

```emacs
M-x slime-connect RET RET RET
```


<a id="org3e8366b"></a>

# What's in the image?

This image contains SBCL binaries built from the latest source code released by the SBCL devs for a variety of OSes and architectures.

Currently, the only modification made to the SBCL source code when building is to remove `-march=armv5` from the `CFLAGS` on 32-bit ARM targets. This is done because recent gcc versions (like the ones in Alpine 3.11 and 3.12) no longer support this target and it can create suboptimal binaries for armv7 (which is the explicit target of these Docker images). This issue has been [reported upstream](https://bugs.launchpad.net/sbcl/+bug/1839783).


<a id="org47c820a"></a>

# Image variants

This image comes in several variants, each designed for a specific use case.


<a id="orgf2cf1db"></a>

## `%%IMAGE%%:<version>`

This is the defacto image. If you are unsure about what your needs are, you probably want to use this one. It is designed to be used both as a throw away container (mount your source code and start the container to start your app), as well as the base to build other images off of. The included SBCL binary was built with the `--fancy` flag. Additionally, these images contain the SBCL source code (at `/usr/local/src/sbcl`) to help facilitate interactive development and exploration (a hallmark of Common Lisp!).

Some of these tags may have names like bullseye or buster in them. These are the suite code names for releases of Debian and indicate which release the image is based on. If your image needs to install any additional packages beyond what comes with the image, you'll likely want to specify one of these explicitly to minimize breakage when there are new releases of Debian.

These images are built off the buildpack-deps image. It, by design, has a large number of extremely common Debian packages.

These images contain the Quicklisp installer, located at `/usr/local/share/common-lisp/source/quicklisp/quicklisp.lisp`. Additionally, there is a script at `/usr/local/bin/install-quicklisp` that will use the bundled installer to install Quicklisp. You can configure the Quicklisp install with the following environment variables:

-   **`QUICKLISP_DIST_VERSION`:** The dist version to use. Of the form yyyy-mm-dd. `latest` means to install the latest version (the default).
-   **`QUICKLISP_CLIENT_VERSION`:** The client version to use. Of the form yyyy-mm-dd. `latest` means to install the latest version (the default).
-   **`QUICKLISP_ADD_TO_INIT_FILE`:** If set to `true`, `(ql:add-to-init-file)` is used to add code to the implementation's user init file to load Quicklisp on startup. Not set by default.

Additionally, these images contain cl-launch to provide a uniform interface to running a Lisp implementation without caring exactly which implementation is being used (for instance to have uniform CI scripts).


<a id="orgfc15c8c"></a>

## `%%IMAGE%%:<version>-slim`

This image does not contain the common packages contained in the default tag and only contains the minimal packages needed to run SBCL. Unless you are working in an environment where only this image will be deployed and you have space constraints, we highly recommend using the default image of this repository.


<a id="org8d4837e"></a>

## `%%IMAGE%%:<version>-alpine`

This image is based on the popular [Alpine Linux project](https://alpinelinux.org/), available in [the `alpine` official image](https://hub.docker.com/_/alpine). Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

This variant is highly recommended when final image size being as small as possible is desired. The main caveat to note is that it does use [musl libc](https://musl.libc.org/) instead of [glibc and friends](https://www.etalabs.net/compare_libcs.html), so certain software might run into issues depending on the depth of their libc requirements. However, most software doesn't have an issue with this, so this variant is usually a very safe choice. See [this Hacker News comment thread](https://news.ycombinator.com/item?id=10782897) for more discussion of the issues that might arise and some pro/con comparisons of using Alpine-based images.

To minimize image size, it's uncommon for additional related tools (such as git or bash) to be included in Alpine-based images. Using this image as a base, add the things you need in your own Dockerfile (see the [alpine image description](https://hub.docker.com/_/alpine/) for examples of how to install packages if you are unfamiliar).


<a id="org563afc8"></a>

## `%%IMAGE%%:<version>-windowsservercore`

This image is based on [Windows Server Core (`microsoft/windowsservercore`)](https://hub.docker.com/_/microsoft-windows-servercore). As such, it only works in places which that image does, such as Windows 10 Professional/Enterprise (Anniversary Edition) or Windows Server 2016.

This image contains msys2 along with some common packages used for building foreign code. The goal is to have foreign packages installed to make it equivalent to default Debian images. If there's something missing, please open an issue!

For information about how to get Docker running on Windows, please see the relevant "Quick Start" guide provided by Microsoft:

-   [Windows Server Quick Start](https://msdn.microsoft.com/en-us/virtualization/windowscontainers/quick_start/quick_start_windows_server)
-   [Windows 10 Quick Start](https://msdn.microsoft.com/en-us/virtualization/windowscontainers/quick_start/quick_start_windows_10)


<a id="orgead3ba9"></a>

# License

SBCL is licensed using a mix of BSD-style and public domain licenses. See SBCL's [COPYING](http://sbcl.git.sourceforge.net/git/gitweb.cgi?p=sbcl/sbcl.git;a=blob_plain;f=COPYING;hb=HEAD) file for more info.

The Dockerfiles used to build the images are licensed under BSD-2-Clause.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
