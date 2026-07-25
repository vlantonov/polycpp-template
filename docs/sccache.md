# sccache in polycpp-template

## What this template does

sccache integration is wired through cmake/Sccache.cmake. When sccache is
available on PATH and POLYCPP_USE_SCCACHE is ON (default), it is configured as
C and C++ compiler launcher for the build.

## Local development

By default, sccache stores local artifacts in:
- ~/.cache/sccache on Linux/macOS
- %LOCALAPPDATA%/Mozilla/sccache on Windows

No remote backend is configured by default. After a build, run:

```bash
sccache --show-stats
```

Use this to inspect cache hit-rate and compile volume.

## CI backend (default)

In GitHub Actions, this template uses mozilla-actions/sccache-action@v0.0.7.
That action enables the GitHub Actions cache backend by exporting:
- SCCACHE_GHA_ENABLED=true
- ACTIONS_CACHE_URL
- ACTIONS_RUNTIME_TOKEN

No additional workflow-side backend configuration is required beyond adding the
action step. For public repositories, this backend is free within GitHub
Actions cache quotas.

## Optional S3-compatible remote backend

For self-hosted or cross-repo caching, configure an S3-compatible backend with:
- SCCACHE_BUCKET
- SCCACHE_REGION
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

This works with AWS S3, MinIO, Cloudflare R2, and Backblaze B2.

To use this in GitHub Actions, add these values as repository or organization
secrets and inject them into workflow env for build jobs. This can replace the
GHA cache backend when you want a shared backend across multiple repos.

## MSVC gotcha

MSVC /Zi embeds PDB timestamps that break stable cache keys. cmake/Sccache.cmake
forces /Z7 to avoid this issue. Do not remove that guard unless you also
replace it with an equivalent cache-stable debug format strategy.

## Advanced: cache Conan dependency builds

By default, only the top-level CMake build is launched via sccache. To also
cache C/C++ compilation inside Conan --build=missing dependency builds, add to
your Conan profile:

```ini
[conf]
tools.build:compiler_executables={"c": "sccache gcc", "cpp": "sccache g++"}
```

Trade-off: larger cache footprint in exchange for faster clean builds when
frequently rebuilding dependencies.
