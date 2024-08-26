param (
    [string]$FilePaths,
    [string]$HashesFilePath
)

$versions = @{}
$sha = [System.Security.Cryptography.SHA1]::Create();

foreach ($filePath in $FilePaths.Split(';'))
{
    if (-not (Test-Path $filePath))
    {
        Write-Host "File not found: $filePath"

        continue
    }

    [system.io.stream]$stream = [system.io.File]::OpenRead($filePath)
    try
    {
        [byte[]]$bytes = New-Object byte[] $stream.length
        [void]$stream.Read($bytes, 0, $stream.Length);
    }
    finally
    {
        $stream.Close();
    }

    $hash = $sha.ComputeHash($bytes);
    $versions[$filePath] = [System.BitConverter]::ToString($hash).Replace('-', '');

    Write-Host "Hashed $filePath"
}

$sha.Dispose();

$versions.GetEnumerator() | Select Name, Value | Export-Csv $HashesFilePath