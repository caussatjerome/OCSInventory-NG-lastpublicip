'Wscript.Echo _
'	"<LASTPUBLICIP>" & VbCrLf &_
'	"<IP>" & test & "</IP>" & VbCrLf &_
'	"<CITY>" & ADVersion & "</CITY>" & VbCrLf &_
'	"<ORG>" & ADAlias & "</ORG>" & VbCrLf &_
'	"</LASTPUBLICIP>"
'pays : ifconfig.co/country
'ifconfig.co/city
'le mieu :
'ifconfig.co/json
'( "ip": "xx.xx.xx.xx","country": "France","region_name": "Hauts-de-France","asn_org": "SFR SA",)


' Script is designed to be run with cscript.exe
'liste de serveurs :
url1 = "https://ipinfo.io/json"'ok
url2 = "https://ifconfig.co/json"'ok
url3 = "http://ip-api.com/json"'ok
url4 = "https://ipwhois.app/json/"'ok

'random select serveur :
Dim max,min
max=4
min=1
Randomize
serv = Int((max-min+1)*Rnd+min)
Select Case serv
case 1 url = url1
case 2 url = url2
case 3 url = url3
case 4 url = url4
case 5 url = url5
end Select

'requette http
Set req = CreateObject("Microsoft.XMLHTTP")
req.open "GET", url, False
req.setRequestHeader "User-Agent", "Mozilla/5.0"
req.setRequestHeader "Accept", "application/json"
req.setRequestHeader "charset", "UTF-8"
req.send

If req.Status = 200 Then
'réponse recu
recu = "," & req.responseText & ","
'enlève les guillemets et les acolades
StringWithQuotes = Replace(recu, Chr(34), "")
StringWithQuotes = Replace(StringWithQuotes, "}", "")
StringWithQuotes = Replace(StringWithQuotes, "{", "")
'suprime les espaces avant / après double point :
StringWithQuotes = Replace(StringWithQuotes, ": ", ":")
StringWithQuotes = Replace(StringWithQuotes, " :", ":")
'remplace les mot clé pour le reste du code :
StringWithQuotes = Replace(StringWithQuotes, "region_name:", "region:")
StringWithQuotes = Replace(StringWithQuotes, "organisation:", "asn_org:")
StringWithQuotes = Replace(StringWithQuotes, "org:", "asn_org:")
StringWithQuotes = Replace(StringWithQuotes, "as:", "asn:")
StringWithQuotes = Replace(StringWithQuotes, "query:", "ip:")
StringWithQuotes = Replace(StringWithQuotes, "zip:", "codepostal:")
'debug : Wscript.Echo StringWithQuotes

'trouve la position du mot ip :
findposIP = InStr(StringWithQuotes,"ip:") + 3
findposIPEND = InStr(findposIP,StringWithQuotes,",") - findposIP
ip = Mid(StringWithQuotes,findposIP,findposIPEND)
'trouve la position du mot country :
findposIP = InStr(StringWithQuotes,"country:") + 8
findposEND = InStr(findposIP,StringWithQuotes,",") - findposIP
country = Mid(StringWithQuotes,findposIP,findposEND)
'trouve la position du mot region :
findposIP = InStr(StringWithQuotes,"region:") + 7
findposEND = InStr(findposIP,StringWithQuotes,",") - findposIP
region = Mid(StringWithQuotes,findposIP,findposEND)
'trouve la position du mot city :
findposIP = InStr(StringWithQuotes,"city:") + 5
findposEND = InStr(findposIP,StringWithQuotes,",") - findposIP
city = Mid(StringWithQuotes,findposIP,findposEND)
'on met le tous ensemble :
geo = city & ", " & region & ", " & country

'trouve la position du mot asn_org :
findposIP = InStr(StringWithQuotes,"asn_org:") + 8
findposEND = InStr(findposIP,StringWithQuotes,",") - findposIP
asn_org = Mid(StringWithQuotes,findposIP,findposEND)
'trouve la position du mot asn si le serveur est le 1:
If serv > 1 then
findposIP = InStr(StringWithQuotes,"asn:") + 4
findposEND = InStr(findposIP,StringWithQuotes,",") - findposIP
asn = Mid(StringWithQuotes,findposIP,findposEND)
fai = asn & " " & asn_org
else
fai = asn_org
End If

Wscript.Echo _
	"<LASTPUBLICIP>" & VbCrLf &_
	"<SERVER>" & url & "(" & serv & ")" & "</SERVER>" & VbCrLf &_
	"<IP>" & ip & "</IP>" & VbCrLf &_
	"<CITY>" & geo & "</CITY>" & VbCrLf &_
	"<ORG>" & fai & "</ORG>" & VbCrLf &_
	"</LASTPUBLICIP>"
End If
