- [Supported Tags](#org93d25ae)
  - [Simple Tags](#org65189c6)
  - [Shared Tags](#org9f5c5bc)
- [Quick Reference](#orgf417aa1)
- [What is SBCL?](#org09acba4)
- [What's in the image?](#org15b30d5)
  - [`-fancy` images](#org48f80eb)
  - [`-build` images](#orgad04556)
- [License](#org18b5f74)



<a id="org93d25ae"></a>

# Supported Tags


<a id="org65189c6"></a>

## Simple Tags

INSERT-SIMPLE-TAGS


<a id="org9f5c5bc"></a>

## Shared Tags

INSERT-SHARED-TAGS


<a id="orgf417aa1"></a>

# Quick Reference

-   **SBCL Home Page:** [http://sbcl.org](http://sbcl.org)
-   **Where to file Docker image related issues:** <https://gitlab.common-lisp.net/cl-docker-images/sbcl>
-   **Where to file issues for SBCL itself:** [https://bugs.launchpad.net/sbcl](https://bugs.launchpad.net/sbcl)
-   **Maintained by:** [Eric Timmons](https://github.com/daewok)
-   **Supported platforms:** `linux/amd64`, `linux/arm64/v8`, `linux/arm/v7`, `windows/amd64`


<a id="org09acba4"></a>

# What is SBCL?

From [SBCL's Home Page](http://sbcl.org):

> Steel Bank Common Lisp (SBCL) is a high performance Common Lisp compiler. It is open source / free software, with a permissive license. In addition to the compiler and runtime system for ANSI Common Lisp, it provides an interactive environment including a debugger, a statistical profiler, a code coverage tool, and many other extensions.


<a id="org15b30d5"></a>

# What's in the image?

This image contains SBCL binaries built from the latest source code released by the SBCL devs for a variety of OSes and architectures.

The goal is to track upstream as closely as possible. Thus, patches are kept to a minimum (and ideally kept for only as long as it takes for them to be upstreamed).

Currently, the only modification made to the SBCL source code when building is to remove `-march=armv5` from the `CFLAGS` on 32-bit ARM targets. This is done because recent gcc versions (like the ones in Alpine 3.11 and 3.12) no longer support this target and it can create suboptimal binaries for armv7 (which is the explicit target of these Docker images). If you would like to build an application with SBCL that is portable to earlier ARM revisions, use the `-build` images (and make sure to `rebuild-sbcl`) as the sources contained in those images are pristine. This issue has been [reported upstream](https://bugs.launchpad.net/sbcl/+bug/1839783).


<a id="org48f80eb"></a>

## `-fancy` images

The tags with a `-fancy` suffix have SBCL built by passing `--fancy` to SBCL's `make.sh`. This results in an image that has additional features added, such as core compression and internal xrefs.


<a id="orgad04556"></a>

## `-build` images

While the build configuration follows upstream's default set of build features, SBCL is very configurable at build time and it would be a shame to not expose this somehow. Therfore, in addition to the standard images, a set of "build" images (tags with the `-build` suffix) are provided.

These build images have SBCL already installed in them and include the SBCL source code and any packages needed to build SBCL from scratch. This allows a customized SBCL to be easily built. To customize the feature set, place a file at `/usr/local/src/sbcl-$SBCL_VERSION/customize-target-features.lisp` or `C:\sbcl-$SBCL_VERSION\customize-target-features.lisp`. See the SBCL build instructions for more details on what this file should contain. To patch SBCL, place any number of patch files (ending in ".patch") in `/usr/local/src/sbcl-${SBCL_VERSION}/patches/` or `C:\sbcl-$SBCL_VERSION\patches\`. To build and install SBCL, execute `rebuild-sbcl`. This script will apply the patches, build, install, and remove the previous copy of SBCL.

While these build images give a lot of flexibility, it results in the images being much larger than the non-build images. Therefore, it is recommended that you use them in [multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/).

Note that the Windows build images do not ship with the full toolchain needed to build SBCL as I have not yet finished my due diligence to understand all the licenses for the tools used (I'm not a Windows developer and don't spend much time on that OS). Until then, the Windows builds will download and install the toolchain as part of the rebuild process.


<a id="org18b5f74"></a>

# License

SBCL is licensed using a mix of BSD-style and public domain licenses. See SBCL's [COPYING](http://sbcl.git.sourceforge.net/git/gitweb.cgi?p=sbcl/sbcl.git;a=blob_plain;f=COPYING;hb=HEAD) file for more info.

The Dockerfiles used to build the images are licensed under BSD-2-Clause.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
