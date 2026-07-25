# polycpp-template

polycpp-template is a reusable monorepo template for orchestrating multiple C++ subprojects with CMake + Conan 2, sccache remote cache, a Dockerized development environment, a GitHub Actions compiler matrix (gcc/clang/MSVC), sanitizers, and CPack .deb/.rpm packaging.

## Status

TBD - CI badges and project health indicators will be added in later steps.

## Supported platforms

| Platform | Environment |
| --- | --- |
| Linux | Ubuntu 22.04+, gcc >=11, clang >=15 |
| macOS | 14, AppleClang >=15 |
| Windows | Server 2022, MSVC 2022 |

## Architecture

TBD - This template follows a `projects/<name>/` monorepo model where the root CMake file orchestrates subprojects and each subproject can publish its own CPack components.

## Dependencies

| Library | Version | Purpose |
| --- | --- | --- |
| spdlog | 1.14.1 | logging (example subprojects) |
| GoogleTest | 1.14.0 | unit + integration tests |

## Build

TBD - filled in by later steps.

## Test

TBD - filled in by later steps.

## Packaging

TBD - filled in by later steps.

## Docker dev environment

TBD - filled in by later steps.