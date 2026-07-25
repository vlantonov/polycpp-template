# Sanitizers

Use sanitizers for memory/thread/UB bug detection during local validation.
Configure each run as RelWithDebInfo.

Conan-generated preset names can vary by environment and generator (for
example, `conan-relwithdebinfo` vs `conan-default`), so this doc uses explicit
`-DCMAKE_TOOLCHAIN_FILE=...` configure commands.

## Local invocation

AddressSanitizer (ASan):

```bash
mkdir -p build && cd build
conan install .. --build=missing -pr:b=default -s build_type=RelWithDebInfo
cd ..
cmake -S . -B build/RelWithDebInfo -G Ninja \
	-DCMAKE_TOOLCHAIN_FILE=build/RelWithDebInfo/generators/conan_toolchain.cmake \
	-DPOLYCPP_ENABLE_ASAN=ON
cmake --build build/RelWithDebInfo
ASAN_OPTIONS=abort_on_error=1 ctest --test-dir build/RelWithDebInfo --output-on-failure
```

UndefinedBehaviorSanitizer (UBSan):

```bash
mkdir -p build && cd build
conan install .. --build=missing -pr:b=default -s build_type=RelWithDebInfo
cd ..
cmake -S . -B build/RelWithDebInfo -G Ninja \
	-DCMAKE_TOOLCHAIN_FILE=build/RelWithDebInfo/generators/conan_toolchain.cmake \
	-DPOLYCPP_ENABLE_UBSAN=ON
cmake --build build/RelWithDebInfo
UBSAN_OPTIONS=print_stacktrace=1:halt_on_error=1 ctest --test-dir build/RelWithDebInfo --output-on-failure
```

ThreadSanitizer (TSan):

```bash
mkdir -p build && cd build
conan install .. --build=missing -pr:b=default -s build_type=RelWithDebInfo
cd ..
cmake -S . -B build/RelWithDebInfo -G Ninja \
	-DCMAKE_TOOLCHAIN_FILE=build/RelWithDebInfo/generators/conan_toolchain.cmake \
	-DPOLYCPP_ENABLE_TSAN=ON
cmake --build build/RelWithDebInfo
TSAN_OPTIONS=halt_on_error=1 ctest --test-dir build/RelWithDebInfo --output-on-failure
```

## Mutual exclusion

ASan and TSan cannot be enabled together. cmake/Sanitizers.cmake enforces this
with a configure-time error when both options are ON.

## TSan compatibility notes

TSan requires all linked code to be built with TSan-compatible instrumentation.
Common incompatibilities include OpenMP runtimes (libgomp) and some older
libc++ stacks.

If a subproject uses OpenMP or another incompatible dependency, add a per-target
CMake guard to skip applying TSan flags for that target.

## CI mapping

.github/workflows/sanitizers.yml runs asan/ubsan/tsan in a matrix on
ubuntu-24.04 with clang and RelWithDebInfo, on every push and pull request to
main.
