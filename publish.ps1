param(
    [Parameter(Mandatory)]
    [string]
    $AppKey
)

if (-not (Test-Path artefacts/*.nupkg))
{
    throw 'no packages to publish'
}

dotnet nuget push "artefacts\*.nupkg" -k $AppKey -s https://api.nuget.org/v3/index.json
