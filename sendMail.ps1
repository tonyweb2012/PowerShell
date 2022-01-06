# [System.Net.ServicePointManager]::SecurityProtocol = 'Tls,TLS11,TLS12'

# Send-MailMessage -SmtpServer $smtpserver -UseSsl -From $from -To $recipient -Subject $subject -BodyAsHtml $body -Encoding ([System.Text.Encoding]::UTF8)

# Send-MailMessage -SmtpServer $smtpserver -Port 465 -UseSsl -From $from -To $recipient -Subject $subject -BodyAsHtml $body -Encoding ([System.Text.Encoding]::UTF8)

###################################################
# to use this script, use with cmd as follows
# type sendmail_2.ps1 | powershell.exe -noprofile -
###################################################

<#
.SYNOPSIS
   Script to send secure email with attachment
 
.DESCRIPTION
   Long description
 
.EXAMPLE
   Example of how to use this cmdlet
 
.EXAMPLE
   Another example of how to use this cmdlet
 
.PARAMETER ComputerName
    This parameter accepts one or several computers (array)
 
.INPUTS
   Inputs to this cmdlet (if any)
 
.OUTPUTS
   Output from this cmdlet (if any)
 
.NOTES
   General notes
 
.COMPONENT
   The component this cmdlet belongs to
 
.ROLE
   The role this cmdlet belongs to
 
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>

param (`
	$from="it.operationslux@juliusbaer.com", `
	$to="anhtuan.le@juliusbaer.com", `
	$cc="", `
	$bcc="", `
	$subject="[none]", `
	$body="this is the default body content", `
	$attachment=""`
	)

#region SMTP parameters
$SMTPServer = "smtpinzrh.juliusbaer.com"
$SMTPPort = "25"
$Username = "r10569"
#$Password = ConvertTo-SecureString "clearTextPassword" -AsPlainText -Force
$Password = ConvertTo-SecureString "$(Get-Content -Path \\homelux-bjb01.juliusbaer.com\home01$\u56685\_DATA\_PowerShell\emailing\SMTPCreds)" -AsPlainText -Force
$myCreds = New-Object System.Management.Automation.PSCredential ($Username , $Password)
#endregion


#region Prepare message to send
$attachedFiles = @()
$body += "===`r`nrun on $env:COMPUTERNAME"

$MailMessage = @{
  To      = "$to".Split(',')
  From    = "$from"
  Subject = "[SMTP] $subject"
  Body    = "$body"
  Smtp    = "$SMTPServer"
  Port    = "$SMTPPort"
  UseSsl  = $true
  #BodyAsHtml = $true
  Encoding = "UTF8"
}
if ([string]::IsNullOrEmpty($cc) -ne "True") {
	# Write-Debug "[DEBUG] Cc OK"
	$MailMessage += @{ Cc = "$cc".Split(',') }
}

if ($bcc -ne "" -AND $bcc -ne $null) {
	Write-Debug "[DEBUG] Bcc OK"
	$MailMessage += @{ Bcc = "$bcc".Split(',') }
}

# attach only valid files
if ([string]::IsNullOrEmpty($attachment) -ne "True") {
  "Total of provided items : " + "$attachment".Split(',').count 
  "Array Length = " + $attachedFiles.Length
  foreach ( $file in "$attachment".Split(',') ) {
    "$file"
    if ((Test-Path "$file") -eq "True") {
      $attachedFiles += "$file"
    } else {
      "[ERROR] Cannot attach invalid $file file"
    }
	} # endfor
  #"attachedFiles = $attachedFiles"
  #"attachedFiles without quotes var type = " + $attachedFiles.GetType().Name
  #"attachedFiles with quotes var type" + "$attachedFiles".GetType().Name
  #"Array Length = " + $attachedFiles.Length
  if ( $attachedFiles.Length -gt 0 ) {
    #"attachment = " + $attachment
    #$MailMessage += @{ Attachments = "$attachedFiles".Split(' ') }
    $MailMessage += @{ Attachments = $attachedFiles }
  }
} else {
	"[DEBUG] no attachment provided"
}
#forced 
#$MailMessage += @{ Attachments = "$attachment".Split(',') }
#endregion

Send-MailMessage @MailMessage -Credential $myCreds 

