# Blazor.CacheBuster [![NuGet version (SoftCircuits.Silk)](https://img.shields.io/nuget/v/snipervld.Blazor.CacheBuster.svg)](https://www.nuget.org/packages/snipervld.Blazor.CacheBuster/)

Blazor.CacheBuster is a library, which allows to hashify script and style URLs the way `asp-append-version` ASP.NET Core's tag halper works. Also, it automatically hashify URLs within local `.js` and `.mjs` files during publish.

## Purpose

Usually, we use service workers to prevent browsers from caching static files, but there are envirnoments, e.g. Zoom Marketplace, which forbids service workers due to security reasons. That's why this library has been build - to give us an ability to easily provide the new static files to end users without cache reset.

## Framework support

.NET 6, .NET 7, .NET 8 are supported.

## Installation

NuGet Package Manager Console:
```bash
Install-Package snipervld.Blazor.CacheBuster
```

Command line:
```ps1
dotnet add package snipervld.Blazor.CacheBuster
```

## Usage

### Script and Link components

Add `@using global::Blazor.CacheBuster.Components` into `_Imports.razor` file.

Use the `Script` and `Link` components in your Blazor pages (typically, `App.razor`) to automatically hashify URLs:

```razor
<Link rel="stylesheet" Href="css/fonts.css" />
<Script Src="path/to/your/script.js" />
```

These components works the same way the regular `script` and `link` HTML elements work.

### `.js` and `.mjs`

This library automatically processes all scripts during the publish, and appends hashes to `import` statements, if the file or script exist in `publish` directory:

```javascript
// Before hashifying
import { log } from '/js/logging.js';

// After hashifying
import { log } from '/js/logging.js?v=23GFD...<hash>';
```

### Additional MSBuild properties

- **BlazorCacheBuster_AdditionalFilesToHash**: Specify additional files (e.g., JSON) to be included in the hashing process.

  ```xml
  <PropertyGroup>
    <!-- Now, the references to this file json, e.g. -->
    <!-- import data from "./resource.json" assert { type: "json" };-->
    <!-- will be hashed as well, e.g. -->
    <!-- import data from "./resource.json?v=5049F5...<hash>" assert { type: "json" };-->
    <BlazorCacheBuster_AdditionalFilesToHash>docs/info.json</BlazorCacheBuster_AdditionalFilesToHash>
  </PropertyGroup>
  ```

- **BlazorCacheBuster_IgnoreFiles**: Exclude specific scripts from being processed.

  ```xml
  <PropertyGroup>
    <BlazorCacheBuster_IgnoreFiles>wwwroot/js/thirdparty.js</BlazorCacheBuster_IgnoreFiles>
  </PropertyGroup>
  ```

## Limitations

Only native ES modules are supported.
