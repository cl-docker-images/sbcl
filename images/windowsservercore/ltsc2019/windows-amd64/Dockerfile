FROM mcr.microsoft.com/windows/servercore:ltsc2019 as builder

# Switch to powershell and make sure it exits on error
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

# First, install chocolatey
RUN $chocourl = 'https://chocolatey.org/install.ps1'; \
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
    iex ((New-Object System.Net.WebClient).DownloadString($chocourl));

# Next, install msys2
RUN choco install -y msys2;
RUN $newpath = ('C:\tools\msys64\usr\bin;c:\tools\msys64\mingw64\bin;{0}' -f $env:PATH); \
    Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newpath

# Install WIX. We don't install it through chocolatey because dotnet35 seems to
# be broken in chocolatey
RUN $wixurl = 'https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311-binaries.zip'; \
    Invoke-WebRequest -Uri $wixurl -OutFile wix311-binaries.zip; \
    choco install -y unzip; \
    mkdir wix/bin; \
    cd wix/bin; \
    unzip ../../wix311-binaries.zip;

# Install build tools
RUN pacman -S --noconfirm --needed mingw-w64-x86_64-gcc make diffutils patch

# Install prebuilt SBCL
COPY sbcl.1.4.14.nupkg sbcl.1.4.14.nupkg
RUN cinst -y sbcl --source .;

# Download the source
ENV SBCL_VERSION=2.0.6

RUN $sbclurl = ('https://downloads.sourceforge.net/project/sbcl/sbcl/{0}/sbcl-{0}-source.tar.bz2' -f $env:SBCL_VERSION); \
    Write-Host ('Downloading {0}' -f $sbclurl); \
    Invoke-WebRequest -Uri $sbclurl -OutFile sbcl-source.tar.bz2 -UserAgent "NativeHost"; \
    \
    $expectedsha256 = 'FD92D64C1D97CC4F42FE3DCAD2B183BCB225D01CDBA4461634926F2F70ADDDAE'; \
    $actualsha256 = (Get-FileHash sbcl-source.tar.bz2 -Algorithm sha256).Hash; \
    Write-Host ('Verifying sha256 {0} (expected: {1})' -f $actualsha256, $expectedsha256); \
    if ($actualsha256 -ne $expectedsha256) { \
        Write-Host 'SHA256 check FAILED!'; \
        exit 1; \
    };

# Unzip the sources and build them
RUN tar -x -v -f sbcl-source.tar.bz2

WORKDIR "C:\sbcl-$SBCL_VERSION"

COPY patches/ C:/sbcl-patches

RUN $env:WIX = '/c/wix'; \
    sh -c 'for p in /c/sbcl-patches/*.patch; do [ -e "$p" ] || continue; patch -p1 < "$p" || exit 1; done'; \
    sh ./make.sh; \
    sh ./make-windows-installer.sh;

# The builder image is massive because it contains the toolchain. Copy the built
# installer into a new image and install it there.
FROM mcr.microsoft.com/windows/servercore:ltsc2019

LABEL maintainer="etimmons@mit.edu"

ENV SBCL_VERSION=2.0.6

COPY --from=builder "C:\sbcl-$SBCL_VERSION\output\sbcl-$SBCL_VERSION-x86-64-windows-binary.msi" "C:\sbcl-x86-64-windows-binary.msi"

RUN C:\sbcl-x86-64-windows-binary.msi \
    && del "C:\sbcl-x86-64-windows-binary.msi"

ENTRYPOINT ["sbcl"]
