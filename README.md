# Changes Module
A Teraform module for mangement of tags related to module versions.

## Additional Documents
Please read our [LICENSE][lice], [CONTRIBUTING][cont], and [CHANGES][chge]
documents before working in this project and anytime they are updated.

## Overview
This module reads the `CHANGES.md` file and Git history obtain information used
to build tags.

## Usage Notes
This module includes scripting for an `external` data resource.  The scriping
depends on `bash`, `echo`, `git`, `grep`, `sed`, and other commands that should
exist in the environment.

[chge]: ./CHANGES.md
[cont]: ./CONTRIBUTING.md
[lice]: ./LICENSE.md
