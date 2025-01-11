[![Actions Status](https://github.com/lizmat/sourcery/actions/workflows/linux.yml/badge.svg)](https://github.com/lizmat/sourcery/actions) [![Actions Status](https://github.com/lizmat/sourcery/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/sourcery/actions) [![Actions Status](https://github.com/lizmat/sourcery/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/sourcery/actions)

NAME
====

sourcery - Turn a sub / method call into file(s) / linenumbers(s)

SYNOPSIS
========

```raku
use sourcery;

.say for sourcery '"42".Int';   # show where a Str gets converted to Int

.say for sourcery 'say "foo"';  # show where strings are being said
say needle 'say "foo"';         # 'sub say'

.say for sourcery 'Str.Int', :defined;  # instantiate type object
say needle 'Str.Int';           # 'method Int'

use Edit::Files;

edit-files sourcery '42.base("beer")';  # go see where this easter egg lives
```

DESCRIPTION
===========

The sourcery module exports a two subroutines:

  * sourcery

  * needle

EXPORTED SUBROUTINES
====================

Both subroutines are exported by default.

sourcery
--------

The `sourcery` subroutine converts a string consisting of the code of a subroutine or method call, to zero or more file / line-number pairs. Which can then be displayed or used as input to go inspect / edit those files.

The `sourcery` subroutine also takes a single named argument: `:defined`. If specified, will instantiate any type object used as an invocant, so that it will match `class:D:` constraints in dispatching (see e.g. the difference between `"Str.Int"` and `"Str.Int", :defined`.

Inspired by Zoffix's [CoreHackers::Sourcery](https://raku.land/zef:raku-community-modules/CoreHackers::Sourcery) module, with the following differences:

  * generates local file locations instead of URLs

  * not limited to core code, could be used on any loaded codebase

needle
------

The `needle` subroutine takes the same string as with `sourcery` but instead returns a string that can serve as a pattern for highlighting the actual sub / method in the file / line that is being returned.

SELECTIVE IMPORTING
===================

```raku
use sourcery <sourcery>;  # only export sub sourcery
```

By default all functions are exported. But you can limit this to the functions you actually need by specifying the names in the `use` statement.

To prevent name collisions and/or import any subroutine with a more memorable name, one can use the "original-name:known-as" syntax. A semi-colon in a specified string indicates the name by which the subroutine is known in this distribution, followed by the name with which it will be known in the lexical context in which the `use` command is executed.

CAVEATS
=======

Modules that have been loaded from an installation, will refer to the location inside the repository where the original source files are being kept. These files are considered immutable and should not be changed.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/sourcery . Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2022, 2023, 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

