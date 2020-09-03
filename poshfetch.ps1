if(!$IsWindows -and $PSVersionTable.PSEdition -eq "Core") {
    Write-Host -ForegroundColor Red "This script currently only works on Windows 10😔"
    exit 1
}

$info = ,"🐱‍👤$env:UserName@$env:ComputerName"
$info += "--" * $info[0].length
$info += ,("OS:", (Get-CimInstance -Class Win32_OperatingSystem).Caption)
$info += ,("Version:", (Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseId))
$info += ,("Build:", [environment]::OSVersion.Version.Build)
if($PSVersionTable.PSVersion.Major -gt 5) {
    $raw = Get-Uptime
    $formatted = @()
    if($raw.Days) {
        if($raw.Days -gt 1) {
            $formatted += "$($raw.Days) Days"
        } else {
            $formatted += "$($raw.Days) Day"
        }
    }
    if($raw.Hours) {
        if($raw.Hours -gt 1) {
            $formatted += "$($raw.Hours) Hours"
        } else {
            $formatted += "$($raw.Hours) Hour"
        }
    }
    if($raw.Minutes) {
        if($raw.Minutes -gt 1) {
            $formatted += "$($raw.Minutes) Minutes"
        } else {
            $formatted += "$($raw.Minutes) Minute"
        }
    }
    $info += ,("Uptime:", "$($formatted[0..($formatted.length - 2)] -join ', ') and $($formatted[$formatted.length - 1])")
}
$info += ,("Programs:", (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*).length)
if(Test-Path "$HOME\scoop\apps") {
    $info += ,("Packages (scoop):", ((ls "$HOME\scoop\apps").length - 1))
}
if($PSVersionTable.PSEdition -eq "Core") {
    $ShellName = "Powershell Core"
} else {
    $ShellName = "Windows Powershell"
}
$info += ,("Shell:", "$ShellName $($PSVersionTable.PSVersion)")
$info += ,("GPU:", (Get-CimInstance -Class Win32_Processor).Name)
$info += ,("GPU:", (Get-CimInstance -Class Win32_DisplayConfiguration).Description)
$os = (Get-Ciminstance Win32_OperatingSystem)
$used = ($os.TotalVisibleMemorySize - $os.FreePhysicalMemory)
$info += ,("RAM:", ("[$([char]27)[35m" + "=" * [math]::Round($used / 1mb) + " " * [math]::Round($os.FreePhysicalMemory / 1mb) + "$([char]27)[0m] " + ("{0:N1} GB/{1:N1} GB" -f [math]::Round($used / 1mb, 2), [math]::Round($os.TotalVisibleMemorySize / 1mb, 2))))
[System.IO.DriveInfo]::GetDrives() | ForEach-Object {
    if($_.VolumeLabel -eq "") {
        $name = "Local Disk ($($_.Name))"
    } else {
        $name = "$($_.VolumeLabel) ($($_.Name))"
    }
    $used = ($_.TotalSize - $_.AvailableFreeSpace)
    $bar = "=" * [math]::Round(($used / $_.TotalSize) * 30)
    $barFree = " " * ([math]::Round(($_.AvailableFreeSpace / $_.TotalSize) * 30))
    if(($_.TotalSize / 1tb) -gt 1) {
        $outOf = [math]::Round($used / 1tb, 2).ToString() + " TB/" + [math]::Round($_.TotalSize / 1tb, 2).ToString() + " TB"
    } else {
        $outOf = [math]::Round($used / 1gb, 2).ToString() + " GB/" + [math]::Round($_.TotalSize / 1gb, 2).ToString() + " GB"
    }
    $info += ,($name, "[$([char]27)[35m$bar$barFree$([char]27)[0m] $outOf")
}
if($env:WT_SESSION) {
    $term = "Windows Terminal"
} elseif($Host.Name -eq "ConsoleHost") {
    $term = "ConHost"
} elseif($Host.Name) {
    $term = $Host.Name
} else {
    $term = "Unknown"
}
$info += ,("Terminal", $term)

$length = 0
$info[2..($info.length - 1)] | ForEach-Object {
    if($_[0].length -gt $length) {
        $length = $_[0].length
    }
}

$i = 0

"                                ..,
                    ....,,:;+ccllll
      ...,,+:;  cllllllllllllllllll
,cclllllllllll  lllllllllllllllllll
llllllllllllll  lllllllllllllllllll
llllllllllllll  lllllllllllllllllll
llllllllllllll  lllllllllllllllllll
llllllllllllll  lllllllllllllllllll
llllllllllllll  lllllllllllllllllll

llllllllllllll  lllllllllllllllllll
llllllllllllll  lllllllllllllllllll
llllllllllllll  lllllllllllllllllll
llllllllllllll  lllllllllllllllllll
llllllllllllll  lllllllllllllllllll
``'ccllllllllll  lllllllllllllllllll
       `' \\*::  :ccllllllllllllllll
                       ````````''*::cll
                                 ````" -split "`r`n" | ForEach-Object {
    if($i -lt $info.length) {
        Write-Host -ForegroundColor Magenta -NoNewLine "$_$([char]27)[40G"
        if($i -eq 1) {
            Write-Host -ForegroundColor DarkGray $info[$i]
        } else {
            if($info[$i].GetType().Name -eq "String") {
                Write-Host -ForegroundColor Magenta $info[$i]
            } else {
                Write-Host -ForegroundColor Magenta -NoNewLine $info[$i][0] (" " * ($length - $info[$i][0].length))
                Write-Host $info[$i][1]
            }
        }
        $i++
    } else {
        Write-Host -ForegroundColor Magenta $_
    }
}
