# Contributing

## Commit convention

Commit subjects follow:

semver(<major|minor|patch>): <imperative summary>

Use .github/skills/semver-commit-description/SKILL.md for release-impact
classification and body structure.

Commit bodies should follow this format:
- Why
- What changed
- Compatibility
- Validation

## Branching model

- Create feature branches from main.
- Open pull requests targeting main.
- main is the release branch.
- Releases are tagged as v<version>.

## Local Definition of Done

Before asking for review, run the local gates below.

1. Conan install succeeds (use a clean build directory and, when needed, a clean cache).

```bash
mkdir -p build && cd build
conan install .. --build=missing -pr:b=default -s build_type=Release
cd ..
```

2. Configure strict clang build.

```bash
cmake --preset conan-release -DPOLYCPP_WARNINGS_AS_ERRORS=ON -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
```

3. Build succeeds.

```bash
cmake --build build/Release
```

4. All tests pass.

```bash
ctest --test-dir build/Release --output-on-failure
```

5. cppcheck gate passes.

```bash
find projects -type d \( -name include -o -name src -o -name tests \) -print0 |
  xargs -0 cppcheck --enable=warning,style,performance,portability \
    --error-exitcode=1 --suppress=missingIncludeSystem --inline-suppr
```

6. clang-format gate passes.

```bash
clang-format-18 --dry-run --Werror $(git ls-files '*.cpp' '*.hpp' '*.c' '*.h')
```

7. Packaging-affecting changes only: package generation succeeds.

```bash
cd build/Release && cpack -G "DEB;RPM"
```

8. Docker-affecting changes only: Docker dev image builds.

```bash
docker build -f Dockerfile.dev .
```

## Adding a new subproject

Use docs/adding-subproject.md for the full checklist and examples.
