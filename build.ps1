<#
.SYNOPSIS
  Run a Makefile target inside WSL, where GnuCOBOL is installed.
.EXAMPLE
  .\build.ps1                                        # make all
  .\build.ps1 test                                   # run library tests
  .\build.ps1 run -Name tutorials\01-hello\hello.cob # build + run one program
#>
param(
    [string]$Target = 'all',
    [string]$Name
)

$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
    $makeArgs = @($Target)
    if ($Name) { $makeArgs += "NAME=$($Name -replace '\\', '/')" }
    wsl make @makeArgs
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
