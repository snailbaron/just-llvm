load("@bazel_skylib//lib:paths.bzl", "paths")
load("@rules_cc//cc:action_names.bzl", "ACTION_NAMES", "ACTION_NAME_GROUPS")
load(
    "@rules_cc//cc:cc_toolchain_config_lib.bzl",
    "action_config",
    "feature",
    "flag_group",
    "flag_set",
    "tool",
)
load("@rules_cc//cc:defs.bzl", "cc_common")

FEATURES = [
    feature(
        name = "cxx-standard",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = ACTION_NAME_GROUPS.all_cpp_compile_actions +
                          ACTION_NAME_GROUPS.all_cc_link_actions,
                flag_groups = [flag_group(flags = ["-std=c++26"])],
            ),
        ],
    ),
    feature(
        name = "use-libcxx",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = ACTION_NAME_GROUPS.all_cpp_compile_actions +
                          ACTION_NAME_GROUPS.all_cc_link_actions,
                flag_groups = [flag_group(flags = ["-stdlib=libc++"])],
            ),
        ],
    ),
    feature(
        name = "use-libunwind",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = ACTION_NAME_GROUPS.all_cc_link_actions,
                flag_groups = [flag_group(flags = ["-unwindlib=libunwind"])],
            ),
        ],
    ),
    feature(
        name = "use-compiler-rt",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = ACTION_NAME_GROUPS.all_cc_link_actions,
                flag_groups = [flag_group(flags = ["-rtlib=compiler-rt"])],
            ),
        ],
    ),
    feature(
        name = "use-lld",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = ACTION_NAME_GROUPS.all_cc_link_actions,
                flag_groups = [flag_group(flags = ["-fuse-ld=lld"])],
            ),
        ],
    ),
    feature(
        name = "verbose-compile",
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.cpp_compile,
                ],
                flag_groups = [flag_group(flags = ["--verbose"])],
            ),
        ],
    ),
    feature(
        name = "verbose-link",
        flag_sets = [
            flag_set(
                actions = ACTION_NAME_GROUPS.all_cc_link_actions,
                flag_groups = [flag_group(flags = ["-Wl,--verbose"])],
            ),
        ],
    ),
    feature(
        name = "no-canonical-prefixes",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = ACTION_NAME_GROUPS.all_cc_compile_actions,
                flag_groups = [
                    flag_group(flags = ["-no-canonical-prefixes"]),
                ],
            ),
        ],
    ),
    feature(
        name = "static-cxx-stdlib",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = ACTION_NAME_GROUPS.all_cc_link_actions,
                flag_groups = [
                    flag_group(flags = [
                        "-static-libstdc++",
                        "-l:libc++abi.a",
                        "-static-libgcc",
                    ]),
                ],
            ),
        ],
    ),
]

def _toolchain_config_impl(ctx):
    # type: (ctx) -> struct

    llvm_root = paths.dirname(paths.dirname(ctx.file._clangxx.path))

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = "llvm",
        compiler = "clang",
        features = FEATURES,
        action_configs = [
            action_config(
                action_name = ACTION_NAMES.cpp_compile,
                tools = [
                    tool(tool = ctx.file._clangxx),
                ],
            ),
            action_config(
                action_name = ACTION_NAMES.cpp_link_executable,
                tools = [
                    tool(tool = ctx.file._clangxx),
                ],
            ),
        ],
        cxx_builtin_include_directories = [
            paths.join(llvm_root, "include/x86_64-unknown-linux-gnu/c++/v1"),
            paths.join(llvm_root, "include/c++/v1"),
            paths.join(llvm_root, "lib/clang/21/include"),
            "/usr/local/include",
            "/usr/include",
        ],
    )

toolchain_config = rule(
    implementation = _toolchain_config_impl,
    attrs = {
        "_clangxx": attr.label(
            default = "@llvm//:bin/clang++",
            allow_single_file = True,
        ),
    },
)
