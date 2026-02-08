## Description

This is a poor man's LLVM toolchain for Bazel: download whatever's available from https://github.com/llvm/llvm-project/releases, and try to sort of make it work. The toolchain will use LLVM stuff for C++ (libc++, unwinder, compiler runtime) and statically link them into the generated binaries. That does **not** mean statically linked binaries. Notably, glibc is linked dynamically.

This toolchain is not hermetic. Mostly because the available LLVM binaries are dynamically linked to a lot of crap (e.g. `lld` to `libxml2.so.2`).

## Usage

`.bazelrc`

```
common --registry=https://raw.githubusercontent.com/snailbaron/registry/main
common --registry=https://bcr.bazel.build
```

`MODULE.bazel`

```
bazel_dep(name = "just-llvm", version = "...")
register_toolchains("@just-llvm//toolchains:llvm")
```
