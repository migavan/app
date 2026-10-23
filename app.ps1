$t1 = 'TlRMTVNTUAABAAAAB4IIAAAAAAAAAAAAAAA='
function Get-NtlmServer($url) {
  $r = (curl.exe -sk -i $url -H "Authorization: NTLM $t1") -join "`n"
  $m = [regex]::Match($r, 'WWW-Authenticate: NTLM ([A-Za-z0-9+/=]{20,})')
  if (-not $m.Success) { return '(нет challenge)' }
  $b = [Convert]::FromBase64String($m.Groups[1].Value)
  $len = [BitConverter]::ToUInt16($b, 40); $off = [BitConverter]::ToInt32($b, 44)
  $i = $off
  while ($i -lt $off + $len) {
    $t = [BitConverter]::ToUInt16($b, $i); $l = [BitConverter]::ToUInt16($b, $i + 2)
    if ($t -eq 0) { break }
    if ($t -eq 1) { return [Text.Encoding]::Unicode.GetString($b, $i + 4, $l) }
    $i += 4 + $l
  }
}
1..10 | ForEach-Object { Get-NtlmServer 'https://mail.xxx.ru/EWS/Exchange.asmx' } | Group-Object | Format-Table Count, Name
