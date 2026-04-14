# Plugin "Get IP" OCSInventory
# Author: Valentin COSSE & Valentin DEVILLE

function Get-FirstPropertyValue {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Object,

        [Parameter(Mandatory = $true)]
        [string[]]$Names
    )

    foreach ($name in $Names) {
        $property = $Object.PSObject.Properties[$name]
        if ($null -ne $property -and -not [string]::IsNullOrWhiteSpace([string]$property.Value)) {
            return [string]$property.Value
        }
    }

    return ''
}

function ConvertTo-XmlText {
    param(
        [AllowNull()]
        [object]$Value
    )

    if ($null -eq $Value) {
        return ''
    }

    return [System.Security.SecurityElement]::Escape([string]$Value)
}

$providers = @(
    @{ Id = 1; Uri = 'https://ipinfo.io/json' },
    @{ Id = 2; Uri = 'https://ifconfig.co/json' },
    @{ Id = 3; Uri = 'http://ip-api.com/json' },
    @{ Id = 4; Uri = 'https://ipwhois.app/json/' }
)

$headers = @{
    'User-Agent' = 'Mozilla/5.0'
    'Accept'     = 'application/json'
}

$lastPublicIp = $null

foreach ($provider in ($providers | Sort-Object { Get-Random })) {
    try {
        $myjson = Invoke-RestMethod -Uri $provider.Uri -Headers $headers -TimeoutSec 15 -ErrorAction Stop

        $ip = Get-FirstPropertyValue -Object $myjson -Names @('ip', 'query')
        if ([string]::IsNullOrWhiteSpace($ip)) {
            continue
        }

        $city = Get-FirstPropertyValue -Object $myjson -Names @('city')
        $region = Get-FirstPropertyValue -Object $myjson -Names @('region', 'region_name', 'regionName')
        $country = Get-FirstPropertyValue -Object $myjson -Names @('country')
        $asn = Get-FirstPropertyValue -Object $myjson -Names @('asn', 'as')
        $asnOrg = Get-FirstPropertyValue -Object $myjson -Names @('asn_org', 'org', 'organisation', 'organization', 'isp', 'asname')

        $geo = @($city, $region, $country) |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
            ForEach-Object { [string]$_ }

        $org = @($asn, $asnOrg) |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
            ForEach-Object { [string]$_ }

        $lastPublicIp = [pscustomobject]@{
            Server = '{0}({1})' -f $provider.Uri, $provider.Id
            IP     = $ip
            City   = $geo -join ', '
            Org    = $org -join ' '
        }

        break
    }
    catch {
        continue
    }
}

$xml = '<LASTPUBLICIP>'

if ($null -ne $lastPublicIp) {
    $xml += '<SERVER>' + (ConvertTo-XmlText $lastPublicIp.Server) + '</SERVER>'
    $xml += '<IP>' + (ConvertTo-XmlText $lastPublicIp.IP) + '</IP>'
    $xml += '<CITY>' + (ConvertTo-XmlText $lastPublicIp.City) + '</CITY>'
    $xml += '<ORG>' + (ConvertTo-XmlText $lastPublicIp.Org) + '</ORG>'
}

$xml += '</LASTPUBLICIP>'

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::WriteLine($xml)
