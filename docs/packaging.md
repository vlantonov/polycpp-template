# Packaging

## Component model

Each subproject should tag install rules with per-component names:
- <name>_runtime for executables and shared runtime artifacts
- <name>_dev for library headers and CMake export/config files

cmake/Packaging.cmake maps each component to separate DEB and RPM outputs.

## Local invocation

Generate packages from an already configured Linux build tree:

```bash
cd build/Release
cpack -G "DEB;RPM"
```

Prerequisites:
- DEB tooling: dpkg-deb (package dpkg-dev)
- RPM tooling: rpmbuild (package rpm)

On Ubuntu:

```bash
sudo apt install dpkg-dev rpm
```

## Expected outputs

With the two example subprojects in this template, each generator emits three
packages:
- polycpp-hello-lib
- polycpp-hello-lib-dev (polycpp-hello-lib-devel for RPM)
- polycpp-hello-app

## CI packaging flow

.github/workflows/package.yml runs on:
- tag push matching v*.*.*
- workflow_dispatch

The workflow builds package artifacts and, on tag pushes, uploads them as GitHub
Release assets.

## Signing

This template ships unsigned packages by default.

To add signing, configure:
- CPACK_DEBIAN_PACKAGE_SIGNKEY for dpkg-sig integration
- CPACK_RPM_PACKAGE_SIGNKEY for rpmsign integration

Signing is release-infrastructure specific and intentionally left out of the
base template.

## Cross-distro caveat

DEB and RPM outputs are not universally portable across major distro versions.
A .deb built on Ubuntu 24.04 typically targets Ubuntu 24.04 / Debian 12 era
systems. Older environments may require building in a matching distro/container.
Use the same principle for RPM: build on the target distro family/version (or a
matching container) when compatibility is strict.
