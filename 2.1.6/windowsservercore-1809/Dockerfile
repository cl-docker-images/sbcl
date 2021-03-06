#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
FROM mcr.microsoft.com/windows/servercore:1809

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

ENV SBCL_VERSION 2.1.6
ENV SBCL_SOURCE_SHA256 8b210c5dd20a466ca438bc7f628812640d0b4acdfad20bec168a6a5dabc1cdef

RUN echo 'Saving original machine PATH'; \
    $machineKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\ControlSet001\Control\Session Manager\Environment\'); \
    $machinePath = $machineKey.GetValue('PATH', [string]::Empty, 'DoNotExpandEnvironmentNames').ToString(); \
    $machineKey.Close(); \
    \
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    echo 'Installing choco'; \
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); \
    Import-Module 'C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1'; \
    \
    echo 'Installing unzip'; \
    choco install -y unzip; \
    \
    echo 'Installing WIX. As of last check, dotnet35 is broken in chocolatey'; \
    Invoke-WebRequest -Uri 'https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311-binaries.zip' -OutFile wix311-binaries.zip; \
    mkdir wix/bin; \
    cd wix/bin; \
    unzip ../../wix311-binaries.zip; \
    cd ../../; \
    rm wix311-binaries.zip; \
    \
    echo 'Installing SBCL 1.4.14'; \
    Invoke-WebRequest -Uri 'https://github.com/sbcl/sbcl/raw/master/tools-for-build/sbcl.1.4.14.nupkg' -OutFile sbcl.1.4.14.nupkg; \
    choco install -y sbcl --source .; \
    refreshenv; \
    sbcl --version; \
    sbcl --eval '(print (+ 1 2))'; \
    rm sbcl.1.4.14.nupkg; \
    \
    echo 'Installing msys2'; \
    choco install -y msys2 --params '/NoUpdate' ; \
    $env:PATH = ('C:\tools\msys64\usr\bin;c:\tools\msys64\mingw64\bin;{0}' -f $env:PATH); \
    \
    echo 'Installing build tools'; \
    pacman -S --noconfirm --needed mingw-w64-x86_64-gcc make diffutils tar; \
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
    sh -c 'tar -x -v -f sbcl-source.tar.bz2'; \
    rm sbcl-source.tar.bz2; \
    cd sbcl-$env:SBCL_VERSION; \
    \
    echo 'Building SBCL'; \
    $env:WIX = '/c/wix'; \
    sh ./make.sh --with-sb-linkable-runtime ; \
    sh ./make-windows-installer.sh; \
    cd ..; \
    \
    echo 'Removing WIX.'; \
    rm -r wix; \
    \
    echo 'Removing msys2'; \
    choco uninstall -y msys2; \
    Remove-Item -Force -Recurse -Path C:\tools; \
    \
    echo 'Removing build SBCL'; \
    choco uninstall -y sbcl; \
    \
    echo 'Removing chocolatey'; \
    Remove-Item -Force -Recurse -Path C:\ProgramData\chocolatey; \
    $machineKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\ControlSet001\Control\Session Manager\Environment\', $true); \
    $machineKey.SetValue('PATH', $machinePath, 'ExpandString'); \
    $machineKey.Close(); \
    [Environment]::SetEnvironmentVariable('ChocolateyInstall', [string]::Empty, 'User'); \
    [Environment]::SetEnvironmentVariable('ChocolateyInstall', [string]::Empty, 'Machine'); \
    [Environment]::SetEnvironmentVariable('ChocolateyLastPathUpdate', [string]::Empty, 'User'); \
    [Environment]::SetEnvironmentVariable('ChocolateyLastPathUpdate', [string]::Empty, 'Machine'); \
    [Environment]::SetEnvironmentVariable('ChocolateyToolsLocation', [string]::Empty, 'User'); \
    [Environment]::SetEnvironmentVariable('ChocolateyToolsLocation', [string]::Empty, 'Machine'); \
    \
    echo 'Installing SBCL'; \
    cp C:\sbcl-$env:SBCL_VERSION\output\sbcl-$env:SBCL_VERSION-x86-64-windows-binary.msi sbcl-installer.msi; \
    Start-Process msiexec.exe -Wait -ArgumentList '/I C:\sbcl-installer.msi'; \
    echo 'Removing SBCL Source'; \
    Remove-Item -Force -Recurse -Path C:\sbcl-$env:SBCL_VERSION; \
    Remove-Item -Force -Path C:\sbcl-installer.msi;

CMD ["sbcl"]
