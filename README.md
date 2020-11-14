# p6perl

# Table of Contents

- [p6perl](#p6perl)
- [Table of Contents](#table-of-contents)
  - [Badges](#badges)
  - [Summary](#summary)
  - [Contributing](#contributing)
  - [Code of Conduct](#code-of-conduct)
  - [Changes](#changes)
  - [Usage](#usage)
    - [init.zsh:](#initzsh)
  - [Author](#author)

## Badges

[![License](https://img.shields.io/badge/License-Apache%202.0-yellowgreen.svg)](https://opensource.org/licenses/Apache-2.0) [![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/p6m7g8/p6perl) [![Mergify](https://img.shields.io/endpoint.svg?url=https://gh.mergify.io/badges/p6m7g8/p6perl/&style=flat)](https://mergify.io)

## Summary

- This README.md is a living example of `bin/doc_readme.pl`.
- `lib/perl5/P6/CLI.pm` is a living example of `bin/doc_inline.pl`.

```shell
# Makefile
make doc
```

```shell
# direct
perl p6perl/bin/doc_inline.pl --module foo
perl p6perl/bin/doc_readme.pl --module foo > foo/README.md
```

## Contributing

- [How to Contribute](CONTRIBUTING.md)

## Code of Conduct

- [Code of Conduct](CODE_OF_CONDUCT.md)

## Changes

- [Change Log](CHANGELOG.md)

## Usage

```shell
p6perl/bin/doc_inline.pl -h
Usage:
    inline.pl --module=<module> [--debug] [--verbose [1-4]] [--no-execute] |
    [--version | --help]

Options:
    --module=<module>
        Which module to work on [REQUIRED]
```

```shell
p6perl/bin/doc_readme.pl -h
Usage:
    readme.pl --module=<module> [--debug] [--verbose [1-4]] [--no-execute] |
    [--version | --help]

Options:
    --module=<module>
        Which module to work on [REQUIRED]
```

### init.zsh:

- p6_perl_init(dir)
- p6df::modules::p6perl::deps()
- p6df::modules::p6perl::external::brew()
- p6df::modules::p6perl::init()


## Author

Philip M . Gollucci <pgollucci@p6m7g8.com>
