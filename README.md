# Scrub

Simple macOS cleaner tool.

## Usage

Using `Scrub` is rather simple:

```
scrub <operation> <file-name-to-clean> [--spaces <spaces>] [--force]
```

Currently, `scrub` provides three operations, namely `uninstall`, `clean`, and `list`. All these
operations take the name (or part of the name) of an application. This name is then used to locate
files on the filesystem and perform the operation. For example, both `scrub uninstall Numbers` and 
`scrub uninstall bers` can be used to uninstall `Numbers` from the system.

Searching for files is not done on a system-wide basis, instead only the usual directories for
storing files are searched. These directories are referred to as search spaces, which are stored in
a spaces `plist` file. Spaces file can be modified to include desired search spaces, or `--spaces`
parameter can be used to provide a custom spaces file.

## Installation

Unfortunately, there is no other way than building `scrub` from the source. This can be done with
the following command:

```
make release
```

## Contributions

I welcome all different forms of contributions to this project, including simply using it. If you
are interested in contributing to the development of scrub, you can report issues or feature
requests, or create pull requests.
