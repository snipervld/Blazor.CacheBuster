if (Test-Path artefacts)
{
    rm -r -fo artefacts
}

dotnet test -c Release

if ($?) {
    dotnet pack -c Release -o artefacts
}
