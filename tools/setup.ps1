# One-click setup for the Corridor 7: Alien Invasion (CD) static recompilation.
# Run it by double-clicking Setup.cmd in the repo folder; the README's "Step by
# step" is the same thing by hand, command for command.
#
# It checks the tools, copies your CD's game files into original\c7, lifts
# CORR7CD.EXE to C, builds build\Release\corridor7.exe (and the self-test, which
# it runs) and leaves a shortcut in this folder. Each step is skipped when its
# output already exists (-Force redoes them), so a rerun after a failure resumes.
# Everything it does goes to setup.log. Nothing of the game is downloaded: it
# comes from your CD (or an image or copy of it).
#
#   -GameDir <drive, folder or .iso>   skip the question (-Game works too)
#   -Yes                               answer yes to every install question
#
# The toolkit is ..\pcrecomp (PCRECOMP_HOME overrides it). Under recomp-launcher
# (RECOMP_LAUNCHER=1) it never waits for Enter, and exit code 0 means the
# shortcut is there.
param([switch]$Force, [switch]$Yes, [Alias('Game')][string]$GameDir = "")
$Game = $GameDir

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$Toolkit = $env:PCRECOMP_HOME
if (-not $Toolkit) { $Toolkit = Join-Path (Split-Path -Parent $Root) 'pcrecomp' }
$env:PCRECOMP_HOME = $Toolkit   # tools\lift.py and CMakeLists.txt read it
$Log = Join-Path $Root 'setup.log'
Set-Location $Root
function Log($t) { Add-Content -Path $Log -Value $t -Encoding UTF8 }
Log "==== setup $(Get-Date -Format s)"

function Say($t, $c = 'Gray') { Write-Host $t -ForegroundColor $c; Log $t }
function Step($n, $t) { Write-Host ""; Say "[$n/5] $t" 'Cyan' }
function Pause-End { if (-not $Yes -and $env:RECOMP_LAUNCHER -ne '1') { Read-Host "Press Enter to close" | Out-Null } }
function Fail($t) {
  Say ""; Say "Setup stopped: $t" 'Red'
  Say "The details are in $Log. Fix that and run Setup.cmd again; finished steps are skipped." 'Yellow'
  Pause-End; exit 1
}
trap { Fail "$_" }
function Ask($q) { if ($Yes) { Say "$q yes"; return $true }; $a = Read-Host "$q [Y/n]"; return -not ($a -match '^[nN]') }
function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}
function Have($exe) { [bool](Get-Command $exe -ErrorAction SilentlyContinue) }
# Run a program with its output in the log. Windows PowerShell turns a native
# program's stderr into errors, so 'Stop' is off while it runs.
function Exec([string[]]$cmd) {
  $old = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
  $rest = @($cmd | Select-Object -Skip 1)
  & $cmd[0] @rest 2>&1 | ForEach-Object { Log "$_" }
  $code = $LASTEXITCODE
  $ErrorActionPreference = $old
  return $code
}
function Run($what, [string[]]$cmd) {
  Say "  $what..."
  $code = Exec $cmd
  if ($code -ne 0) { Fail "$what failed (exit code $code)." }
}
function Winget($name, $id, $size, [string[]]$extra = @()) {
  if (-not (Ask "  Install $name now (winget, $size)?")) { Fail "$name is required." }
  if (-not (Have winget)) { Fail "winget is missing. Install $name yourself." }
  Exec (@('winget', 'install', '-e', '--id', $id, '--accept-package-agreements', '--accept-source-agreements') + $extra) | Out-Null
  Refresh-Path
}

if ($env:RECOMP_LAUNCHER -ne '1') { Clear-Host }
Say "Corridor 7: Alien Invasion (CD): static recompilation setup" 'White'
Say "You need your own copy of the Corridor 7 CD (the USA release), an .iso of it, or a folder copy of it, and about 1 GB free."

# ---------------------------------------------------------------- tools
Step 1 "Checking the tools"
# A Python that answers "Python 3.x". The Store's placeholder "python" answers
# nothing, so asking is the reliable test. The lifter needs only the stdlib.
function Find-Python {
  $user = @(Get-ChildItem "$env:LOCALAPPDATA\Programs\Python\Python3*\python.exe" -ErrorAction SilentlyContinue | Sort-Object FullName -Descending | ForEach-Object { ,@($_.FullName) })
  foreach ($c in (@(@('py', '-3'), @('python'), @('python3')) + $user)) {
    if (-not (Have $c[0])) { continue }
    $old = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    $rest = @($c | Select-Object -Skip 1)
    $v = (& $c[0] @rest --version 2>&1 | Out-String).Trim()
    $ErrorActionPreference = $old
    if ($v -match '^Python 3\.(\d+)' -and [int]$Matches[1] -ge 8) { return ,$c }
  }
  return $null
}
$pyargs = Find-Python
if (-not $pyargs) {
  Say "  Python 3 is not installed. It runs the lifter (tools\lift.py)."
  Winget 'Python 3.12' 'Python.Python.3.12' 'for your user only, about 30 MB' @('--scope', 'user')
  $pyargs = Find-Python
  if (-not $pyargs) { Fail "Python installed, but it can't be found. Install Python 3.12 from python.org yourself." }
}
Say "  Python: $($pyargs -join ' ')"

if (-not (Have cmake)) {
  Say "  CMake is not installed. It configures the build."
  Winget 'CMake' 'Kitware.CMake' 'about 35 MB'
  if (-not (Have cmake)) { Fail "CMake installed, but it is not on PATH yet. Open a new window and run Setup.cmd again." }
}

if (-not (Test-Path (Join-Path $Toolkit 'tools\lift\lift16.py'))) {
  Say "  The pcrecomp toolkit is not beside this folder ($Toolkit)."
  if (-not (Have git)) {
    Say "  git is needed to fetch it."
    Winget 'Git for Windows' 'Git.Git' 'about 60 MB'
    if (-not (Have git)) { Fail "Git did not install. Install Git for Windows yourself." }
  }
  if (-not (Ask "  Download pcrecomp now (git, about 20 MB)?")) { Fail "pcrecomp is required at $Toolkit." }
  Run "Cloning pcrecomp" @('git', 'clone', '--depth', '1', 'https://github.com/sp00nznet/pcrecomp', $Toolkit)
}
Say "  pcrecomp: $Toolkit"

function Find-VS {
  $p = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
  if (Test-Path $p) { return (& $p -latest -version '[17.0,18.0)' -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath) }
  return $null
}
if (-not (Find-VS)) {
  Say "  Visual Studio 2022 with the C++ tools is not installed. The recompiled game is C, and this is the compiler."
  Winget 'the Visual Studio 2022 Build Tools (C++)' 'Microsoft.VisualStudio.2022.BuildTools' 'about 2 GB' `
    @('--override', '--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended')
  if (-not (Find-VS)) { Fail "the Build Tools did not install. Install Visual Studio 2022 with 'Desktop development with C++' yourself." }
}
Say "  C compiler: $(Find-VS)"

# ---------------------------------------------------------------- the game
Step 2 "Copying the CD's game files into original\c7"
if ((Test-Path 'original\c7\CORR7CD.EXE') -and (Test-Path 'original\c7\CORR7.ID') -and -not $Force) {
  Say "  Already there (skipping)."
} else {
  $Game = $Game.Trim('"', ' ')
  if (-not $Game) {
    foreach ($d in (Get-PSDrive -PSProvider FileSystem)) {
      if (Test-Path (Join-Path $d.Root 'CORR7CD\CORR7CD.EXE')) { $Game = $d.Root; Say "  Found the CD in $Game"; break }
    }
  }
  if (-not $Game -and $Yes) { Fail "The CD wasn't found. Give its drive, folder or .iso with -GameDir." }
  while (-not $Game) {
    $Game = (Read-Host "  Where is the CD? Its drive (E:\), a folder copy of it, or an .iso").Trim('"', ' ')
  }
  if ($Game -match '\.iso$') {
    Say "  Mounting $Game"
    $img = Mount-DiskImage -ImagePath (Resolve-Path $Game).Path -PassThru
    $Game = (Get-Volume -DiskImage $img).DriveLetter + ':\'
  }
  # The CD root holds CORR7.ID and the CORR7CD folder; a folder copy of just
  # CORR7CD with CORR7.ID dropped in works too.
  $dir = if (Test-Path (Join-Path $Game 'CORR7CD\CORR7CD.EXE')) { Join-Path $Game 'CORR7CD' } else { $Game }
  if (-not (Test-Path (Join-Path $dir 'CORR7CD.EXE'))) { Fail "CORR7CD.EXE is not in $Game or its CORR7CD folder." }
  $id = @((Join-Path $Game 'CORR7.ID'), (Join-Path $dir 'CORR7.ID')) | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $id) { Fail "CORR7.ID is not in $Game; it is at the root of the CD." }
  Say "  Copying from $dir..."
  New-Item -ItemType Directory -Force 'original\c7' | Out-Null
  Copy-Item -Path (Join-Path $dir '*') -Destination 'original\c7' -Recurse -Force
  Copy-Item $id 'original\c7' -Force
}

# ---------------------------------------------------------------- lift
Step 3 "Recompiling CORR7CD.EXE to C"
if ((Test-Path 'work\c7\gen\recomp_dispatch.c') -and -not $Force) { Say "  Already done (skipping)." }
else { Run "Lifting" ($pyargs + @('tools\lift.py', 'c7')) }

# ---------------------------------------------------------------- build
Step 4 "Building build\Release\corridor7.exe (a few minutes)"
if ((Test-Path 'build\Release\corridor7.exe') -and -not $Force) { Say "  Already built (skipping)." }
else {
  Run "Configuring" @('cmake', '-B', 'build', '-G', 'Visual Studio 17 2022', '-A', 'Win32', "-DPCRECOMP_HOME=$Toolkit")
  Run "Compiling" @('cmake', '--build', 'build', '--config', 'Release', '--', '-m')
}
Run "Running the self-test" @('build\Release\selftest.exe')

# ---------------------------------------------------------------- shortcut
Step 5 "Making the shortcut"
$lnk = Join-Path $Root 'Corridor 7.lnk'
$s = (New-Object -ComObject WScript.Shell).CreateShortcut($lnk)
$s.TargetPath = Join-Path $Root 'build\Release\corridor7.exe'
$s.WorkingDirectory = $Root
$s.Save()
if (-not (Test-Path $lnk)) { Fail "the shortcut was not made." }
Say "  $lnk"
Write-Host ""
Say "Done. Double-click 'Corridor 7' in this folder to play. Alt+Enter toggles fullscreen." 'Green'
Pause-End
exit 0
