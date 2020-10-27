powershell -Command "& 'C:\Program Files\daewok\sbcl\install-toolchain.ps1'"
call C:\ProgramData\chocolatey\bin\RefreshEnv.cmd
bash -c "/c/Program\ Files/daewok/sbcl/rebuild-sbcl"
C:\sbcl-%SBCL_VERSION%\output\sbcl-%SBCL_VERSION%-x86-64-windows-binary.msi
