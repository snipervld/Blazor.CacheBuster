using System.Collections.Concurrent;
using System.Security.Cryptography;
using Microsoft.Extensions.FileProviders;

namespace Blazor.CacheBuster.Extensions;

internal static class FileProviderExtensions
{
    private static readonly ConcurrentDictionary<(string path, DateTimeOffset lastModified), string?> _cachedHashCodes = [];

    public static string? ComputeFileHash(this IFileProvider fileProvider, string? path)
    {
        if (string.IsNullOrEmpty(path))
        {
            return null;
        }

        var fileInfo = fileProvider.GetFileInfo(path);

        if (fileInfo.IsDirectory)
        {
            return null;
        }

        return
            _cachedHashCodes
                .GetOrAdd(
                    (path, fileInfo.LastModified),
                    (info, fileInfo) =>
                    {
                        return fileInfo.ComputeHash();
                    },
                    fileInfo);
    }

    public static string? ComputeHash(this IFileInfo fileInfo)
    {
        if (fileInfo.Exists)
        {
            using Stream stream = fileInfo.CreateReadStream();
            using var sha = SHA1.Create();
            byte[] hash = sha.ComputeHash(stream);

            return BitConverter.ToString(hash).Replace("-", string.Empty);
        }

        return null;
    }
}
