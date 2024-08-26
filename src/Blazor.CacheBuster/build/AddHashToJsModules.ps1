param (
    [string]$FilePaths,
    [string]$HashesFilePath,
    [string]$RootDir
)

$versionsTable = Import-Csv $HashesFilePath
$versions = @{}

foreach ($r in $versionsTable)
{
    $versions[$r.Name] = $r.Value
}

#import ... from '../path/to/script.js'
#import ... from './path/to/script.js'
#import ... from '/path/to/script.js'
#import ... from '.dir/script.js'
#import ... from 'path/to/doc.json' assert { type: "json" };'
$regex = [regex]"^(?<leading>\s*import.*from )(['""])(?<grp>(/|\.\./|\./|\.)[\w+/.]+)\1(?<trailing>([\s;]*)|\s*assert.*)$"

foreach ($filePath in $FilePaths.Split(';'))
{
    if (-not (Test-Path $filePath))
    {
        Write-Host "File not found: $filePath"

        continue
    }

    $fileDir = [IO.Path]::GetDirectoryName($filePath) + '\'

    $content = cat $filePath

    $importedFilesHashes = @{}
    $matches = $content|%{$regex.Match($_)}|?{$_.Success}

    foreach ($m in $matches)
    {
        $path = $m.Groups['grp'].Value

        #if the import path starts with ./ or ..//, concat it with the absolute path to directory, where the current file is located
        if ($path.StartsWith('./') -or $path.StartsWith('../'))
        {
            $fullPath = [IO.Path]::GetFullPath([IO.Path]::Combine($fileDir, $path.TrimStart([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)))
        }
        #otherwise concat the import path with the path to root directory
        else
        {
            $fullPath = [IO.Path]::GetFullPath([IO.Path]::Combine($RootDir, $path.TrimStart([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)))
        }

        $hash = $versions[$fullPath]

        if ($hash)
        {
            Write-Host "Found JS import candidate '$path' for hashing: FullPath='$fullPath';FoundHash='$hash'"
        }
        else
        {
            Write-Host "Found JS import candidate '$path', but there is no hash for it: FullPath='$fullPath'"
        }

        $importedFilesHashes[$path] = $hash
    }

    if ($matches)
    {
        $processedContent = $content|%{$regex.Replace($_, {
            param($match)

            $leading = $match.Groups['leading'].Value
            $quote = $match.Groups[1].Value
            $importPath = $match.Groups['grp'].Value
            $trailing = $match.Groups['trailing'].Value

            #first of all, handle the case, when file extions is ommited
            #(well, it's prohibited by ES standard, but do this check just in case)
            if ($importedFilesHashes[$importPath + '.js'])
            {
                $importFileHash = $importedFilesHashes[$importPath + '.js']
            }
            elseif ($importedFilesHashes[$importPath])
            {
                $importFileHash = $importedFilesHashes[$importPath]
            }
            else
            {
                Write-Host "No hash has been found for JS import '$importPath'"

                return $match.Value
            }

            return "$($leading)$($quote)$($importPath)?v=$($importFileHash)$($quote)$($trailing)"
        })}
    }
    else
    {
        $processedContent = $content
    }

    $processedContent | Out-File $filePath
    Write-Host "Processed $filePath"
}
