load("@io_bazel_rules_go//go/private/rules:library.bzl", _go_library = "go_library")
load("@bazel_gazelle//:deps.bzl", _go_repository = "go_repository")

# Alias retained for future ease of use.
go_library = _go_library

# Maybe download a repository rule, if it doesn't exist already.
def maybe(repo_rule, name, **kwargs):
    if name not in native.existing_rules():
        repo_rule(name = name, **kwargs)

# A wrapper around go_repository to add gazelle directives.
def go_repository(name, **kwargs):
    directives = []
    if "build_directives" in kwargs:
        directives = kwargs["build_directives"]

    directives += [
        "gazelle:map_kind go_library go_library @com_github_fapiper_onchain_access_control//dev/tools/go:def.bzl",
    ]
    kwargs["build_directives"] = directives
    maybe(_go_repository, name, **kwargs)
