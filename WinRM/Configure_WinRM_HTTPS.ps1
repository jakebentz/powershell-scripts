<#
  Configure_WinRM_HTTPS.ps1

  AUTHOR: Jake Bentz
  DATE:	12/23/2025

  REQUIREMENTS: N/A

  DESCRIPTION:  This script creates a self-signed certificate and HTTPS WinRM Listener
  				winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
  				winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname="ServerB.domain.com"; CertificateThumbprint="<cert thumbprint here>"}'
  				Remove-WSManInstance winrm/config/Listener -SelectorSet @{Address="*";Transport="http"}
  				New-WSManInstance winrm/config/Listener -SelectorSet @{Address="*";Transport="http"}
					Additional notes and examples:
					New-SelfSignedCertificate -CertStoreLocation cert:\localmachine\my -DnsName ("servername.domainname.com", "servername") -NotAfter (get-date).AddYears(5) -Provider "Microsoft RSA SChannel Cryptographic Provider" -KeyLength 2048

					winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname="servername.domainname.com";CertificateThumbprint="0000000000000000000000000000000000000000"}'					
					winrm set winrm/config/service '@{AllowUnencrypted="true"}'
					winrm set winrm/config/service/auth '@{Basic="true"}'
					winrm set winrm/config/service/auth '@{Kerberos="true"}'
					winrm set winrm/config/service/auth '@{CredSSP="true"}'
					winrm set winrm/config/service/auth '@{Certificate="true"}'
					winrm set winrm/config/client '@{AllowUnencrypted="true"}'
					winrm set winrm/config/client/auth '@{Basic="true"}'
					winrm set winrm/config/client/auth '@{Kerberos="true"}'
					winrm set winrm/config/client/auth '@{CredSSP="true"}'
					winrm set winrm/config/client/auth '@{Certificate="true"}'
					winrm set winrm/config/client '@{TrustedHosts="host1, host2, host3″}'

					/data/vco/usr/lib/vco/app-server/conf/krb5.conf

					[libdefaults]
					default_realm = domainname.com
					udp_preference_limit = 1
					[realms]
					domainname.com = {
					kdc = servername.domainname.com
					admin_server = servername.domainname.com
					default_domain = domainname.com
					}
					[domain_realm]
					.domainname.com=domainname.com
					domainname.com=domainname.com
					[logging]
					kdc = FILE:/var/log/krb5/krb5kdc.log
					admin_server = FILE:/var/log/krb5/kadmind.log
					default = SYSLOG:NOTICE:DAEMON

  REVISION HISTORY
   VER  DATE        AUTHOR/EDITOR   COMMENT
   1.0  12/23/2025	 Jake Bentz	 Created script
#>

<#
#Delete HTTPS Listener if it already exists
if (dir wsman:\localhost\listener | where {$_.Keys -like "Transport=https*"})
{
winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
}
#>

#Define CN and FQDN
$zone = ".domainname.com"
$fqdn = "$env:computername$zone"
$CN = "CN=$fqdn"

#Create certificate and get thumbprint
New-SelfSignedCertificate -subject $CN -DnsName $fqdn -TextExtension '2.5.29.37={text}1.3.6.1.5.5.7.3.1'
$Thumbprint = Get-ChildItem -Path cert:LocalMachine/My | Where-Object {$_.Subject -eq $CN} | Select Thumbprint
$certificateThumbprint=$Thumbprint.thumbprint

#Create HTTPS listener
New-WSManInstance winrm/config/Listener -SelectorSet @{Address="*";Transport="https"} -ValueSet @{Hostname=$fqdn;CertificateThumbprint=$certificateThumbprint}

#Enumerate Listener
winrm e winrm/config/listener
