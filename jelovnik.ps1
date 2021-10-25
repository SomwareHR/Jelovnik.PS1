Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"
# ------------------------------------------------------------------------------------------------------------------------ [Arguments]
$script:swc_JelovnikMainMenuFile=$args[0]
Set-Location (Split-Path "$script:swc_JelovnikMainMenuFile" -Parent)
IF ( $null -eq $script:swc_JelovnikMainMenuFile )            { Write-Host "Error-01: Missing menu-file name"                                         ; EXIT }
IF ( -not ( Test-Path "$script:swc_JelovnikMainMenuFile" ) ) { Write-Host "Error-02: Menu-file $script:swc_JelovnikMainMenuFile missing or something"; EXIT }
# ------------------------------------------------------------------------------------------------------------------------ [Vars]
$script:Crta74                           = "─" * 74
$script:Crta76                           = "─" * 76
$script:Crta78                           = "─" * 78
$script:swc_JelovnikPreviousMainMenuFile = $script:swc_JelovnikMainMenuFile
$script:CrLf										         = "`r`n"
$script:swv_SelectedMenuItem             = 0
# ------------------------------------------------------------------------------------------------------------------------ [fn_LoadMenu]
function fn_LoadMenu {
	$script:Jelovnik							         = @()
	$script:Jelovnik                       = Import-Csv -Path $script:swc_JelovnikMainMenuFile -Delimiter "|" -Header "Key", "Title", "Command", "Parameters"
	$script:swc_NumberOfMenuItems          = $script:Jelovnik.Length
	$script:swv_CurrentMenuName            = (Get-Item $script:swc_JelovnikMainMenuFile).Basename.ToUpper()
	$script:Blanks                         = " " * ( $script:Crta78.Length - $script:swv_CurrentMenuName.Length - 3 )
}
# ------------------------------------------------------------------------------------------------------------------------ [fn_PrintMenu]
function fn_PrintMenu {
	Clear-Host
	Write-Host "┌$script:Crta78┐$script:CrLf│ $script:swv_CurrentMenuName $script:Blanks │ $script:CrLf└$script:Crta78┘$script:CrLf┌─┬$script:Crta76┐" -ForegroundColor Gray
	FOR ($i = 0; $i -lt $script:swc_NumberOfMenuItems; $i++) {
		$FGColor="Gray"; $BGColor="Black"
		IF ( $i -eq $script:swv_SelectedMenuItem ) { $FGColor="Black"; $BGColor="Cyan" }
		SWITCH ( $script:Jelovnik[$i].Key ) {
			"-"	{ Write-Host "├─┼─"	-NoNewLine; Write-Host $script:Crta74 -NoNewLine -ForegroundColor $FGColor -BackgroundColor $BGColor; Write-Host "─┤" }
			"$"	{ Write-Host "│ │ " -NoNewLine; Write-Host $script:Jelovnik[$i].Title (" " * ( 73 - $script:Jelovnik[$i].Title.Length )) -NoNewLine -ForegroundColor $FGColor -BackgroundColor $BGColor; Write-Host " │" }
			DEFAULT {
				Write-Host "│"                 				-NoNewLine
				Write-Host $script:Jelovnik[$i].Key   -ForegroundColor Cyan -NoNewline
				Write-Host "│ "                				-NoNewLine
				Write-Host $script:Jelovnik[$i].Title  (" " * ( 73 - $script:Jelovnik[$i].Title.Length )) -ForegroundColor $FGColor -BackgroundColor $BGColor -NoNewline; Write-Host " │"
			}
		}
	}
	Write-Host "└─┴$script:Crta76┘" -ForegroundColor Gray
}
# ======================================================================================================================= [-----MAIN-----]
DO {
	fn_LoadMenu
	fn_PrintMenu
	$script:swvUserKeyPress=[System.Console]::ReadKey()
	$script:swvUserKeyPressKey=$script:swvUserKeyPress.Key
	$script:swvUserKeyPressChar=$script:swvUserKeyPress.KeyChar
	#// Write-Host "1:" $script:swvUserKeyPress "2:" $script:swvUserKeyPressKey "3:" $script:swvUserKeyPressChar; timeout.exe 999          # Monitor pressed-key data
	IF ( $script:swvUserKeyPressChar -eq "!"         ) { notepad.exe $script:swc_JelovnikMainMenuFile                                                                   }
	#IF ( $script:swvUserKeyPressKey  -eq "F1"        ) { Get-Content "help.txt" ; [System.Console]::ReadKey()                                                           }
	IF ( $script:swvUserKeyPressKey  -eq "F1"        ) { IF ( Test-Path "$script:swc_JelovnikMainMenuFile.help" ) { Get-Content "$script:swc_JelovnikMainMenuFile.help" ; [System.Console]::ReadKey()	} }
	IF ( $script:swvUserKeyPressKey  -eq "Home"      ) { $script:swv_SelectedMenuItem = 0                                                                               }
	IF ( $script:swvUserKeyPressKey  -eq "End"       ) { $script:swv_SelectedMenuItem = $script:swc_NumberOfMenuItems - 1                                               }
	IF ( $script:swvUserKeyPressKey  -eq "LeftArrow" ) { $script:swc_JelovnikMainMenuFile = $script:swc_JelovnikPreviousMainMenuFile ; $script:swv_SelectedMenuItem = 0 }
	IF ( $script:swvUserKeyPressKey  -eq "DownArrow" ) {
		IF ( $script:swv_SelectedMenuItem                       -lt ( $script:swc_NumberOfMenuItems - 1 ) ) { $script:swv_SelectedMenuItem = $script:swv_SelectedMenuItem + 1 }
		IF ( $script:Jelovnik[$script:swv_SelectedMenuItem].Key -eq	"-"                                   ) { $script:swv_SelectedMenuItem = $script:swv_SelectedMenuItem + 1 }
	}
	IF ( $script:swvUserKeyPressKey  -eq "UpArrow"   ) {
		IF ( $script:swv_SelectedMenuItem                       -gt 0   ) { $script:swv_SelectedMenuItem = $script:swv_SelectedMenuItem - 1 }
		IF ( $script:Jelovnik[$script:swv_SelectedMenuItem].Key -eq	"-" ) { $script:swv_SelectedMenuItem = $script:swv_SelectedMenuItem - 1 }
	}
	IF ( $script:swvUserKeyPressKey -eq "RightArrow") { $script:swvUserKeyPressKey = "Enter" }
	IF ( $script:swvUserKeyPressKey -eq "Enter"     ) {
		SWITCH ( $script:Jelovnik[$script:swv_SelectedMenuItem].Key ) {
			"-" { <# intentionally do nothing #> }
			DEFAULT {
				$script:swvUserKeyPressChar  = $script:Jelovnik[$script:swv_SelectedMenuItem].Key
				$script:swv_SelectedMenuItem = 0
			}
		}
	}
	FOR ($j = 0; $j -lt $script:swc_NumberOfMenuItems; $j++ )          {
		IF ( $script:swvUserKeyPressChar -ceq $script:Jelovnik[$j].Key )   {
			SWITCH ( $script:Jelovnik[$j].Command.Trim() )                     {
				"<LOADMENU>"                                                       {
					$script:swc_JelovnikPreviousMainMenuFile = $script:swc_JelovnikMainMenuFile
					$script:swc_JelovnikMainMenuFile         = $script:Jelovnik[$j].Parameters
					$script:swv_SelectedMenuItem             = 0
				}
				"<ASK>"                                                            {
					Write-Host "$CrLf $CrLf`Confirm $CrLf $CrLf`Command ...... Powershell $CrLf`Parameters ..." $script:Jelovnik[$j].Parameters.Trim() "$CrLf"
					$confirmation = Read-Host "[Y]es or [N]o"
					IF ($confirmation -eq 'Y') { pwsh.exe -command $script:Jelovnik[$j].Parameters; EXIT }
				}
				DEFAULT {	Start-Process $script:Jelovnik[$j].Command.Trim() -ArgumentList $script:Jelovnik[$j].Parameters.Trim(); EXIT } # Exits after executing command, Remove  "; EXIT"  for loop-until-ESC
			}
		}
	}
} until ($script:swvUserKeyPressKey -eq "Escape")
EXIT

# Jelovnik.PS1 v.21.0728.19 (C)2021 https://github.com/SomwareHR License: MIT [SWID#20210725123801]
# Jelovnik.PS1 v.21.0727.08 (C)2021 https://github.com/SomwareHR License: MIT [SWID#20210725123801] ... published 20210728 ... https://github.com/SomwareHR/Jelovnik.PS1
# Jelovnik.PS1 v.21.1025.11 (C)2021 https://github.com/SomwareHR License: MIT [SWID#20210725123801] ... published 20211025 ... https://github.com/SomwareHR/Jelovnik.PS1
