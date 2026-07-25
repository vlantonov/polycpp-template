# Copilot Instructions — polycpp-template

Repo-wide guidance for all agents (including the default agent). Agent-specific
files under `.github/agents/` build on top of this; this file always applies.

## Repo overview

polycpp-template is a reusable monorepo template for orchestrating multiple C++
subprojects from one root build. Each subproject lives under `projects/<name>/`
and is wired into a root CMake orchestrator via guarded `add_subdirectory`
entries. The standardized toolchain is CMake >= 3.25, Conan 2, sccache, CPack
for DEB/RPM output, and a GitHub Actions matrix across Linux/macOS/Windows plus
sanitizers and static checks.

## Repo layout

```text
.
├── CMakeLists.txt          # root orchestrator, add_subdirectory per project
├── conanfile.txt           # pinned third-party deps
├── VERSION                 # single line, semver
├── cmake/                  # reusable CMake helpers (warnings, sanitizers, sccache, clang-tidy, packaging)
├── projects/               # one folder per subproject
│   ├── hello-lib/          # example STATIC library
│   └── hello-app/          # example executable
├── Dockerfile.dev          # reproducible dev environment
├── .devcontainer/          # VS Code Remote Containers config
├── docs/                   # docs/adding-subproject.md, sccache, packaging, sanitizers, docker-dev
└── .github/
    ├── workflows/          # ubuntu / macos / windows / sanitizers / static_check / package
    ├── agents/             # Coder / Interface Architect / Orchestrator / Planner
    ├── skills/             # semver-commit-description / semver-version-publish
    └── copilot-instructions.md
```

## Definition of Done (C++ changes)

A C++ change is **not complete** until all of the following pass locally. These
mirror the gating CI jobs exactly.

Use **clang** for the build gate: it is the strictest compiler in the matrix and
catches warnings GCC does not (for example `-Wunused-lambda-capture`).

Prerequisites: **Conan >= 2.0** and **CMake >= 3.25** (preset support).

1. **Install dependencies with Conan**, then **strict build** via the generated
   CMake preset:

   ```bash
   mkdir -p build && cd build
   conan install .. --build=missing -pr:b=default -s build_type=Release
   cd ..
   cmake --preset conan-release \
     -DPOLYCPP_WARNINGS_AS_ERRORS=ON -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
   cmake --build build/Release
   ```

   `POLYCPP_WARNINGS_AS_ERRORS` defaults to **OFF**, so always pass it `ON` for
   CI-equivalent local validation.

2. **Tests**:

   ```bash
   ctest --test-dir build/Release --output-on-failure
   ```

3. **Static analysis (cppcheck gate)**:

   ```bash
   find projects -type d \( -name include -o -name src -o -name tests \) -print0 |
     xargs -0 cppcheck --enable=warning,style,performance,portability \
       --error-exitcode=1 --suppress=missingIncludeSystem --inline-suppr
   ```

4. **Formatting gate**:

   ```bash
   clang-format-18 --dry-run --Werror $(git ls-files '*.cpp' '*.hpp' '*.c' '*.h')
   ```

5. **Packaging smoke** (only when CPack config, `cmake/Packaging.cmake`, or
   subproject install rules change):

   ```bash
   cd build/Release && cpack -G "DEB;RPM"
   ```

6. **Docker smoke** (only when `Dockerfile.dev`, `.dockerignore`, or
   `.devcontainer/` changes):

   ```bash
   docker build -t polycpp-dev -f Dockerfile.dev .
   docker run --rm polycpp-dev bash -lc 'cmake --version && conan --version && clang --version && cppcheck --version'
   ```

7. **Sanitizer smoke** (only when sanitizer flags, `cmake/Sanitizers.cmake`, or
   memory/threading code changes): run at least one local ASan or TSan flow from
   `docs/sanitizers.md`.

8. **clang-tidy note**: clang-tidy is advisory in CI (`continue-on-error: true`)
   and is not a merge-blocking gate. Document notable warnings and consider
   fixes, but do not treat them as hard failures.

## Dependency management (Conan)

External dependencies are managed with the **Conan** package manager (>= 2.0) —
not hand-vendored, and not pulled ad hoc via CMake `FetchContent`.

- Declare every third-party dependency in a **`conanfile.txt`** at the repo root
  with pinned versions, using the `CMakeDeps` + `CMakeToolchain` generators and
  the `cmake_layout` layout. The file is organized into blocks: a `[requires]`
  block of pinned `name/version` runtime dependencies, a `[test_requires]` block
  for test-only dependencies, a `[generators]` block listing `CMakeDeps` and
  `CMakeToolchain`, and a `[layout]` block set to `cmake_layout`:

  ```ini
  [requires]
  spdlog/1.14.1

  [test_requires]
  gtest/1.14.0

  [generators]
  CMakeDeps
  CMakeToolchain

  [layout]
  cmake_layout
  ```

- Consume packages in CMake through generated `find_package` targets (for
  example `spdlog::spdlog` and `GTest::gtest`).
- `cmake_layout` places generated files and build output under `build/<Config>`
  (for example `build/Release`) when `conan install` is run from `build/`
  against the project root (`conan install ..`). Configure via generated preset
  (`cmake --preset conan-release`) rather than a hand-passed toolchain path.
- `CMakeUserPresets.json` is generated by Conan at the project root and is
  listed in `.gitignore` — do not commit it.
- Before adding a new dependency, prefer one already available on Conan Center.
- Pin versions explicitly; never float on `latest`. Run `conan install` with
  `--build=missing` so missing binaries are built from source deterministically.
- Keep `conanfile.txt` and CMake target wiring in sync — a dependency added to
  one must appear in the other.

## Multi-subproject orchestration rules

- Root `CMakeLists.txt` is the single orchestrator. Never define production
  `add_library` or `add_executable` targets at the root.
- Every subproject lives under `projects/<name>/` and owns its
  `CMakeLists.txt`, `include/`, `src/`, and `tests/` structure.
- Wire each subproject with one `POLYCPP_BUILD_<NAME>` cache option (default ON)
  plus an `EXISTS` guard so stripped-down forks still configure cleanly.
- Every subproject target should apply the three helpers:
  `polycpp_add_strict_warnings(<target>)`,
  `polycpp_apply_sanitizers(<target>)`,
  `polycpp_enable_clang_tidy(<target>)`.
- Every installable subproject declares components: `<name>_runtime` (binaries
  and shared libs) and, for libraries with public headers, `<name>_dev` (headers
  and CMake export files). Both must be represented in
  `cmake/Packaging.cmake` per-component metadata.
- For full onboarding workflow, follow `docs/adding-subproject.md`.

## Docker (dev environment only)

`Dockerfile.dev` exists to provide a reproducible development environment and is
not runtime packaging for deployed services. It is also not exercised by CI,
which installs tools directly on GitHub-hosted runners.

If a subproject needs a runtime image, place that Dockerfile under
`projects/<name>/` and scope its build logic to that subproject's CMake flow;
do not add per-subproject runtime images to the repository root.

## Known cross-cutting gotchas

These are verified false positives or strictness traps in this repo. Handle them
the documented way — do not change otherwise-correct APIs to silence a tool.

- **clang `-Werror` flags unused lambda captures** (`-Wunused-lambda-capture`).
  Capture only what the lambda body uses; drop unused captures.
- **cppcheck false-positive `passedByValue` on `std::string_view`** parameters.
  `string_view` is intentionally passed by value (it is cheap). Suppress with a
  narrow `// cppcheck-suppress passedByValue` on the line above.
- **cppcheck reports `syntaxError` on gtest `TEST_F` fixtures** it cannot parse.
  Add a narrow `// cppcheck-suppress syntaxError` above the first affected
  `TEST_F` in the file.
- Prefer STL algorithms over manual accumulation loops in tests; cppcheck's
  `useStlAlgorithm` style check flags hand-rolled loops.
- Sanitizer mutual exclusion: ASan + TSan cannot coexist;
  `cmake/Sanitizers.cmake` errors at configure time if both flags are ON.
- sccache + MSVC `/Zi` cache-miss trap: `cmake/Sccache.cmake` enforces `/Z7`.
  Do not remove that guard.
- Inline suppressions are honored because CI runs cppcheck with
  `--inline-suppr`. Keep suppressions narrow (single line) and only for genuine
  false positives.
