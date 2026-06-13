param(
  [string]$RootUrl = 'https://bytedance.larkoffice.com/wiki/HRANwGsgpiCGwhkXcwBcDDNdn3e',

  [string[]]$AltUrls = @('https://bytedance.larkoffice.com/wiki/AaL9w540YiK4FjkoNX7cLC2FnJf'),

  [string]$OutRoot = 'miaoxiang_lark_kb',

  [int]$MaxDocs = 300
)

$ErrorActionPreference = 'Stop'

$outRootPath = Join-Path (Get-Location) $OutRoot
$rawDir = Join-Path $outRootPath 'raw_docs'
New-Item -ItemType Directory -Force -Path $rawDir | Out-Null

function Get-Slug([string]$Text) {
  if ([string]::IsNullOrWhiteSpace($Text)) { return 'untitled' }
  $slug = $Text -replace '[\\/:*?"<>|]', '_'
  $slug = $slug -replace '\s+', ' '
  $slug = $slug.Trim()
  if ($slug.Length -gt 80) { $slug = $slug.Substring(0, 80) }
  if ([string]::IsNullOrWhiteSpace($slug)) { return 'untitled' }
  return $slug
}

function Get-Token([string]$Doc) {
  if ($Doc -match '/wiki/([A-Za-z0-9]+)') { return $Matches[1] }
  return $Doc
}

function Get-WikiUrl([string]$Token, [string]$FallbackHost) {
  return "https://$FallbackHost/wiki/$Token"
}

function Fetch-LarkDoc([string]$Doc) {
  $tmpErr = New-TemporaryFile
  try {
    $jsonLines = & lark-cli docs +fetch --api-version v2 --doc $Doc --doc-format markdown --as user --format json 2> $tmpErr.FullName
    $jsonText = ($jsonLines -join "`n").Trim()
    if ([string]::IsNullOrWhiteSpace($jsonText)) {
      $errText = Get-Content -LiteralPath $tmpErr.FullName -Raw -ErrorAction SilentlyContinue
      throw "empty response from lark-cli: $errText"
    }
    return $jsonText | ConvertFrom-Json
  }
  finally {
    Remove-Item -LiteralPath $tmpErr.FullName -Force -ErrorAction SilentlyContinue
  }
}

$rootUri = [System.Uri]$RootUrl
$fallbackHost = $rootUri.Host

$queue = [System.Collections.Generic.Queue[string]]::new()
$seen = @{}
$records = [System.Collections.Generic.List[object]]::new()
$edges = [System.Collections.Generic.List[object]]::new()
$failures = [System.Collections.Generic.List[object]]::new()
$externalLinks = [System.Collections.Generic.List[object]]::new()

$queue.Enqueue($RootUrl)
foreach ($url in $AltUrls) {
  if (-not [string]::IsNullOrWhiteSpace($url)) { $queue.Enqueue($url) }
}

while ($queue.Count -gt 0 -and $seen.Count -lt $MaxDocs) {
  $doc = $queue.Dequeue()
  $token = Get-Token $doc
  if ($seen.ContainsKey($token)) { continue }
  $seen[$token] = $true
  Write-Host "FETCH $token"

  try {
    $res = Fetch-LarkDoc $doc
    if (-not $res.ok) {
      $message = if ($res.error.message) { $res.error.message } else { 'lark-cli returned ok=false' }
      throw $message
    }

    $document = $res.data.document
    $content = [string]$document.content
    $title = 'untitled'
    if ($content -match '<title>(.*?)</title>') {
      $title = [System.Net.WebUtility]::HtmlDecode($Matches[1])
    }

    $fileName = '{0}_{1}.md' -f $token, (Get-Slug $title)
    $path = Join-Path $rawDir $fileName
    $frontMatter = @(
      '---',
      "source: $doc",
      "token: $token",
      "document_id: $($document.document_id)",
      "revision_id: $($document.revision_id)",
      "title: $title",
      "fetched_at: $(Get-Date -Format o)",
      '---',
      ''
    ) -join "`r`n"
    Set-Content -LiteralPath $path -Value ($frontMatter + $content) -Encoding utf8NoBOM

    $linkedTokens = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($m in [regex]::Matches($content, 'https?://[^/"]+/wiki/([A-Za-z0-9]+)')) {
      [void]$linkedTokens.Add($m.Groups[1].Value)
    }
    foreach ($m in [regex]::Matches($content, '<cite[^>]+file-type="wiki"[^>]+doc-id="([A-Za-z0-9]+)"')) {
      [void]$linkedTokens.Add($m.Groups[1].Value)
    }
    foreach ($m in [regex]::Matches($content, '<cite[^>]+doc-id="([A-Za-z0-9]+)"[^>]+file-type="wiki"')) {
      [void]$linkedTokens.Add($m.Groups[1].Value)
    }
    foreach ($lt in $linkedTokens) {
      $edges.Add([pscustomobject]@{ from = $token; to = $lt }) | Out-Null
      if (-not $seen.ContainsKey($lt)) {
        $queue.Enqueue((Get-WikiUrl $lt $fallbackHost))
      }
    }

    foreach ($m in [regex]::Matches($content, 'https?://[^\s<>"\)]+')) {
      $url = $m.Value
      if ($url -notmatch '/wiki/[A-Za-z0-9]+') {
        $externalLinks.Add([pscustomobject]@{ from = $token; url = $url }) | Out-Null
      }
    }

    $records.Add([pscustomobject]@{
      token = $token
      title = $title
      document_id = $document.document_id
      revision_id = $document.revision_id
      source = $doc
      file = $path
      link_count = $linkedTokens.Count
      content_chars = $content.Length
    }) | Out-Null
  }
  catch {
    $failures.Add([pscustomobject]@{
      token = $token
      source = $doc
      error = $_.Exception.Message
    }) | Out-Null
  }
}

$records | Export-Csv -LiteralPath (Join-Path $outRootPath 'documents.csv') -NoTypeInformation -Encoding utf8NoBOM
$edges | Export-Csv -LiteralPath (Join-Path $outRootPath 'links.csv') -NoTypeInformation -Encoding utf8NoBOM
$failures | Export-Csv -LiteralPath (Join-Path $outRootPath 'failures.csv') -NoTypeInformation -Encoding utf8NoBOM
$externalLinks | Export-Csv -LiteralPath (Join-Path $outRootPath 'external_links.csv') -NoTypeInformation -Encoding utf8NoBOM

$indexPath = Join-Path $outRootPath 'README.md'
$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add('# Lark Wiki local knowledge base') | Out-Null
$lines.Add('') | Out-Null
$lines.Add("Fetched at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')") | Out-Null
$lines.Add("Root: $RootUrl") | Out-Null
$lines.Add("Success: $($records.Count)") | Out-Null
$lines.Add("Failures: $($failures.Count)") | Out-Null
$lines.Add("Internal links: $($edges.Count)") | Out-Null
$lines.Add("External links: $($externalLinks.Count)") | Out-Null
$lines.Add('') | Out-Null
$lines.Add('## Documents') | Out-Null
foreach ($r in $records) {
  $rel = Resolve-Path -LiteralPath $r.file -Relative
  $lines.Add("- [$($r.title)]($rel) token=$($r.token) revision=$($r.revision_id)") | Out-Null
}
if ($failures.Count -gt 0) {
  $lines.Add('') | Out-Null
  $lines.Add('## Failures') | Out-Null
  foreach ($f in $failures) {
    $lines.Add("- $($f.token): $($f.error)") | Out-Null
  }
}
Set-Content -LiteralPath $indexPath -Value ($lines -join "`r`n") -Encoding utf8NoBOM

[pscustomobject]@{
  outRoot = $outRootPath
  success = $records.Count
  failures = $failures.Count
  internalLinks = $edges.Count
  externalLinks = $externalLinks.Count
  documents = $records | Select-Object token, title, revision_id, link_count, content_chars
  failed = $failures
} | ConvertTo-Json -Depth 6
