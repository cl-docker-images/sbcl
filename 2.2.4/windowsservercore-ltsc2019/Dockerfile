#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
FROM mcr.microsoft.com/windows/servercore:ltsc2019

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV MSYS2_VERSION 20210725

# Install msys and update it.
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest -UseBasicParsing -uri "https://github.com/msys2/msys2-installer/releases/download/2021-07-25/msys2-base-x86_64-$env:MSYS2_VERSION.sfx.exe" -OutFile msys2.exe; \
    .\msys2.exe -y -oC:\; \
    Remove-Item msys2.exe ; \
    function msys() { C:\msys64\usr\bin\bash.exe @('-lc') + @Args; } \
    msys ' '; \
    msys 'pacman --noconfirm -Syuu'; \
    msys 'pacman --noconfirm -Syuu'; \
    msys 'pacman --noconfirm -Scc'; \
    \
    echo 'Killing msys2 subprocesses'; \
    taskkill /F /FI 'MODULES eq msys-2.0.dll'; \
    \
    echo 'Clearing Recycle Bin (see https://github.com/docker/for-win/issues/8910)'; \
    If (Test-Path 'C:\$Recycle.Bin') { Remove-Item -Force -Recurse -Path 'C:\$Recycle.Bin'; };

# Install common tools. Eventually make this equivalent to buildpack-deps.
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    function msys() { C:\msys64\usr\bin\bash.exe @('-lc') + @Args; } \
    $env:CHERE_INVOKING = 'yes'; \
    $env:MSYSTEM = 'MINGW64'; \
    msys 'pacman -S --noconfirm --needed mingw-w64-x86_64-gcc make diffutils tar unzip mingw-w64-x86_64-zlib git' \
    \
    echo 'Installing WIX.'; \
    Invoke-WebRequest -Uri 'https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311-binaries.zip' -OutFile wix311-binaries.zip; \
    mkdir wix/bin; \
    cd wix/bin; \
    msys 'unzip ../../wix311-binaries.zip'; \
    cd ../../; \
    rm wix311-binaries.zip; \
    \
    echo 'Killing msys2 subprocesses'; \
    taskkill /F /FI 'MODULES eq msys-2.0.dll'; \
    \
    echo 'Clearing Recycle Bin (see https://github.com/docker/for-win/issues/8910)'; \
    If (Test-Path 'C:\$Recycle.Bin') { Remove-Item -Force -Recurse -Path 'C:\$Recycle.Bin'; };

ENV SBCL_VERSION 2.2.4
ENV SBCL_SOURCE_SHA256 fcdd251cbc65f7f808ed0ad77246848d1be166aa69a17f7499600184b7a57202

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    function msys() { C:\msys64\usr\bin\bash.exe @('-lc') + @Args; } \
    $env:CHERE_INVOKING = 'yes'; \
    $env:MSYSTEM = 'MINGW64'; \
    $env:MSYS2_PATH_TYPE = 'inherit'; \
    \
    echo 'Downloading the bootstrap SBCL'; \
    Invoke-WebRequest -Uri 'https://github.com/sbcl/sbcl/releases/download/sbcl-1.4.14/sbcl-1.4.14-x86-64-windows-binary.msi' -OutFile sbcl-bootstrap.msi; \
    Start-Process msiexec.exe -Wait -ArgumentList '/I C:\sbcl-bootstrap.msi'; \
    rm sbcl-bootstrap.msi; \
    $env:SBCL_HOME = 'C:\Program Files\Steel Bank Common Lisp\1.4.14\'; \
    $env:PATH = ('C:\Program Files\Steel Bank Common Lisp\1.4.14\;{0}' -f $env:PATH); \
    \
    echo 'Downloading SBCL source'; \
    $sbclurl = ('https://downloads.sourceforge.net/project/sbcl/sbcl/{0}/sbcl-{0}-source.tar.bz2' -f $env:SBCL_VERSION); \
    Invoke-WebRequest -Uri $sbclurl -OutFile sbcl-source.tar.bz2 -UserAgent "NativeHost"; \
    $actualsha256 = (Get-FileHash sbcl-source.tar.bz2 -Algorithm sha256).Hash; \
    Write-Host ('Verifying sha256 {0} (expected: {1})' -f $actualsha256, $env:SBCL_SOURCE_SHA256); \
    if ($actualsha256 -ne $env:SBCL_SOURCE_SHA256) { \
        Write-Host 'SHA256 check FAILED!'; \
        exit 1; \
    }; \
    \
    echo 'Unpacking source'; \
    msys 'tar -x -v -f sbcl-source.tar.bz2'; \
    Remove-Item -Force -Path C:\sbcl-source.tar.bz2; \
    cd sbcl-$env:SBCL_VERSION; \
    \
    echo 'Building SBCL'; \
    $env:WIX = '/c/wix'; \
    msys 'echo "(setf *debugger-hook* (lambda (c h) (declare (ignore h)) (let ((restart (find-restart `'continue c))) (when restart (invoke-restart restart)))))" > build-debugger-hook.lisp'; \
    msys './make.sh --xc-host="sbcl --load build-debugger-hook.lisp" --with-sb-linkable-runtime'; \
    msys 'rm build-debugger-hook.lisp'; \
    msys './make-windows-installer.sh'; \
    cd ..; \
    \
    echo 'Installing SBCL'; \
    cp C:\sbcl-$env:SBCL_VERSION\output\sbcl-$env:SBCL_VERSION-x86-64-windows-binary.msi sbcl-installer.msi; \
    Start-Process msiexec.exe -Wait -ArgumentList '/I C:\sbcl-installer.msi'; \
    echo 'Removing SBCL Source'; \
    Remove-Item -Force -Recurse -Path C:\sbcl-$env:SBCL_VERSION; \
    Remove-Item -Force -Path C:\sbcl-installer.msi; \
    \
    echo 'Killing msys2 subprocesses'; \
    taskkill /F /FI 'MODULES eq msys-2.0.dll'; \
    \
    echo 'Clearing Recycle Bin (see https://github.com/docker/for-win/issues/8910)'; \
    If (Test-Path 'C:\$Recycle.Bin') { Remove-Item -Force -Recurse -Path 'C:\$Recycle.Bin'; };

CMD ["sbcl"]
