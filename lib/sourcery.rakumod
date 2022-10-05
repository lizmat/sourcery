my sub sourcery(Str:D $call, :$defined) {

    my sub invocant-capture(Str:D $invocant, Str:D $args) {
        ($args
          ?? '\(' ~ $invocant ~ ', ' ~ $args ~ ')'
          !! '\(' ~ $invocant ~ ')'
        ).EVAL
    }

    my sub do-sourcery(@blocks, $capture) {
        my $path := $*EXECUTABLE.parent.parent.parent.absolute ~ $*SPEC.dir-sep;
        @blocks.map: -> $block {
            if $block.cando($capture) {
                my $file := $block.file;
                $file := $file.starts-with('SETTING::')
                  ?? $path ~ $file.substr(9)
                  !! $file.subst(
                       /^ \w+ '#' /,
                       { 
                           CompUnit::RepositoryRegistry.file-for-spec($/.Str)
                           ~ $*SPEC.dir-sep
                       }
                     ).subst(/ ' (' <-[)]>+ ')' $/);
                $file => $block.line;
            }
        }
    }

    (my $invocant, my $rest) = $call.split('.', 2);
    if $rest.defined {  # assume method call
        my $self = $invocant.EVAL;
        if $defined && !$self.DEFINITE {
            $invocant ~= '.CREATE';
            $self = $self.CREATE;
        }

        (my $method, my $args) = $rest.split('(', 2);
        my $capture := do if $args.defined {
            invocant-capture($invocant, $args.chop);
        }
        else {
            ($method, $args) = $rest.split(':', 2);
            invocant-capture($invocant, $args // "");
        }

        do-sourcery $self.^can($method).map(*.candidates.Slip), $capture;
    }
    else {              # assume sub call
        (my $name, my $args) = $call.split('(', 2);
        my $capture := do if $args.defined {
            ('\(' ~ $args).EVAL
        }
        else {
            ($name, $args) = $call.split(/ \s+ /, 2);
            $capture := $args.defined
              ?? ('\(' ~ $args.trim ~ ')').EVAL
              !! \()
        }
        do-sourcery ::("&$name").candidates, $capture;
    }
}

my sub needle(Str:D $call) {
    (my $, my $rest) = $call.split('.', 2);

    if $rest.defined {  # assume method call
        (my $name, my $args) = $rest.split('(', 2);
        ($name, $args) = $rest.split(':', 2) unless $args.defined;
        "method $name"
    }
    else {              # assume sub call
        (my $name, my $args) = $call.split('(', 2);
        ($name, $args) = $call.split(/ \s+ /, 2) unless $args.defined;
        "sub $name"
    }
}

my sub EXPORT(*@names) {
    Map.new: @names
      ?? @names.map: {
             if UNIT::{"&$_"}:exists {
                 UNIT::{"&$_"}:p
             }
             else {
                 my ($in,$out) = .split(':', 2);
                 if $out && UNIT::{"&$in"} -> &code {
                     Pair.new: "&$out", &code
                 }
             }
         }
      !! UNIT::.grep: {
             .key.starts-with('&') && .key ne '&EXPORT'
         }
}

=begin pod

=head1 NAME

sourcery - Turn a sub / method call into file(s) / linenumbers(s)

=head1 SYNOPSIS

=begin code :lang<raku>

use sourcery;

.say for sourcery '"42".Int';   # show where a Str gets converted to Int

.say for sourcery 'say "foo"';  # show where strings are being said
say needle 'say "foo"';         # 'sub say'

.say for sourcery 'Str.Int', :defined;  # instantiate type object
say needle 'Str.Int';           # 'method Int'

use Edit::Files;

edit-files sourcery '42.base("beer")';  # go see where this easter egg lives

=end code

=head1 DESCRIPTION

The sourcery module exports a two subroutines:

=item sourcery
=item needle

=head1 EXPORTED SUBROUTINES

Both subroutines are exported by default.

=head2 sourcery

The C<sourcery> subroutine converts a string consisting of the code of
a subroutine or method call, to zero or more file / line-number pairs.
Which can then be displayed or used as input to go inspect / edit those
files.

The C<sourcery> subroutine also takes a single named argument: C<:defined>.
If specified, will instantiate any type object used as an invocant, so that
it will match C<class:D:> constraints in dispatching (see e.g. the
difference between C<"Str.Int"> and C<"Str.Int", :defined>.

Inspired by Zoffix's L<CoreHackers::Sourcery|https://raku.land/zef:raku-community-modules/CoreHackers::Sourcery>
module, with the following differences:

=item generates local file locations instead of URLs
=item not limited to core code, could be used on any loaded codebase

=head2 needle

The C<needle> subroutine takes the same string as with C<sourcery> but
instead returns a string that can serve as a pattern for highlighting
the actual sub / method in the file / line that is being returned.

=head1 SELECTIVE IMPORTING

=begin code :lang<raku>

use sourcery <sourcery>;  # only export sub sourcery

=end code

By default all functions are exported.  But you can limit this to
the functions you actually need by specifying the names in the C<use>
statement.

To prevent name collisions and/or import any subroutine with a more
memorable name, one can use the "original-name:known-as" syntax.  A
semi-colon in a specified string indicates the name by which the subroutine
is known in this distribution, followed by the name with which it will be
known in the lexical context in which the C<use> command is executed.

=head1 CAVEATS

Modules that have been loaded from an installation, will refer to the
location inside the repository where the original source files are
being kept.  These files are considered immutable and should not be
changed.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/sourcery .
Comments and Pull Requests are welcome.

If you like this module, or what I’m doing more generally, committing to a
L<small sponsorship|https://github.com/sponsors/lizmat/>  would mean a great
deal to me!

=head1 COPYRIGHT AND LICENSE

Copyright 2022 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
