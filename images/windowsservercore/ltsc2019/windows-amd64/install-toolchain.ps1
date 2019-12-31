# Make sure we exit on error.
$ErrorActionPreference = 'Stop'

cd C:\

# First, install chocolatey
$chocourl = 'https://chocolatey.org/install.ps1'
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString($chocourl))

# Next, install msys2
choco install -y msys2

$newpath = ('C:\tools\msys64\usr\bin;c:\tools\msys64\mingw64\bin;{0}' -f $env:PATH);
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newpath

# Install WIX. We don't install it through chocolatey because dotnet35 seems to
# be broken in chocolatey
$wixurl = 'https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311-binaries.zip'
Invoke-WebRequest -Uri $wixurl -OutFile wix311-binaries.zip
choco install -y unzip
mkdir wix/bin
cd wix/bin
unzip ../../wix311-binaries.zip

cd C:\

refreshenv

# Install build tools
C:\tools\msys64\usr\bin\bash -c "/usr/bin/pacman -S --noconfirm --needed mingw-w64-x86_64-gcc make diffutils patch"
