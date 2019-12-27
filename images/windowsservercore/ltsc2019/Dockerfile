# This Dockerfile is derived largely from SBCL's azure-pipelines.yml
# (https://github.com/sbcl/sbcl/blob/cf9dff3b59e4ae0025dbfa542e73c7f1235382c0/azure-pipelines.yml#L62)
FROM mcr.microsoft.com/windows/servercore:ltsc2019 as builder

# Switch to powershell and make sure it exits on error
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

ENV SBCL_VERSION=1.5.9

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

# Install prebuilt SBCL
COPY sbcl.1.4.14.nupkg sbcl.1.4.14.nupkg
RUN cinst -y sbcl --source .;

# Download the source
RUN $sbclurl = ('https://downloads.sourceforge.net/project/sbcl/sbcl/{0}/sbcl-{0}-source.tar.bz2' -f $env:SBCL_VERSION); \
    Write-Host ('Downloading {0}' -f $sbclurl); \
    Invoke-WebRequest -Uri $sbclurl -OutFile sbcl-source.tar.bz2 -UserAgent "NativeHost"; \
    \
    $sha256 = 'CBDB0D25E8A4B02B8369A667A289C8F0CE1D4EBB4E565E9191A31F1AE9A4B9B6'; \
    Write-Host ('Verifying sha256 ({0})' -f $sha256); \
    if ((Get-FileHash sbcl-source.tar.bz2 -Algorithm sha256).Hash -ne $sha256) { \
        Write-Host 'SHA256 check FAILED!'; \
        exit 1; \
    };

# Install build tools
RUN pacman -S --noconfirm --needed mingw-w64-x86_64-gcc make diffutils

# Unzip the sources and build them
RUN tar -x -v -f sbcl-source.tar.bz2

WORKDIR "C:\sbcl-$SBCL_VERSION"

RUN $env:WIX = '/c/wix'; \
    sh ./make.sh; \
    sh ./make-windows-installer.sh;

# The builder image is massive because it contains the toolchain. Copy the built
# installer into a new image and install it there.
FROM mcr.microsoft.com/windows/servercore:ltsc2019

LABEL maintainer="etimmons@mit.edu"

ENV SBCL_VERSION=1.5.9

COPY --from=builder "C:\sbcl-$SBCL_VERSION\output\sbcl-$SBCL_VERSION-x86-64-windows-binary.msi" "C:\sbcl-x86-64-windows-binary.msi"

RUN C:\sbcl-x86-64-windows-binary.msi \
    && del "C:\sbcl-x86-64-windows-binary.msi"

ENTRYPOINT ["sbcl"]
