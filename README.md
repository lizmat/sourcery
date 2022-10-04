[![Actions Status](https://github.com/lizmat/sourcery/actions/workflows/test.yml/badge.svg)](https://github.com/lizmat/sourcery/actions)

NAME
====

sourcery - turn a sub / method call into file(s) / linenumbers(s)

SYNOPSIS
========

```raku
use sourcery;

.say for sourcery '"42".Int';   # show where a Str gets converted to Int

.say for sourcery 'say "foo"';  # show where strings are being said

.say for sourcery "Str.Int", :defined;  # instantiate type object

use Edit::Files;

edit-files sourcery '42.base("beer")';  # go see where this easter egg lives
```

DESCRIPTION
===========

The sourcery module exports a single subroutine called `sourcery`. It converts a piece of code consisting of a subroutine or method call to zero or more file / line-number pairs. Which can then be displayed or used as input to go inspect / edit those files.

The `sourcery` subroutine also takes a single named argument: `:defined`. If specified, will instantiate any type object used as an invocant, so that it will match `class:D:` constraints in dispatching (see e.g. the difference between `"Str.Int"` and `"Str.Int", :defined`.

Inspired by Zoffix's [CoreHackers::Sourcery](https://raku.land/zef:raku-community-modules/CoreHackers::Sourcery) module, with the following differences:

  * generates local file locations instead of URLs

  * not limited to core code, could be used on any loaded codebase

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

Copyright 2022 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

