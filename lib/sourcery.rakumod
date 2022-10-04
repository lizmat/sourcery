my sub invocant-capture(Str:D $invocant, Str:D $args) {
    ($args
      ?? '\(' ~ $invocant ~ ', ' ~ $args ~ ')'
      !! '\(' ~ $invocant ~ ')'
    ).EVAL
}

my sub do-sourcery($seq, $capture) {
    my $path := $*EXECUTABLE.parent.parent.parent.absolute ~ $*SPEC.dir-sep;
    $seq.map: -> $block {
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

my sub sourcery(Str:D $call, :$defined) is export {
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

        do-sourcery $self.^can($method), $capture;
    }
    else {              # assume sub call
        (my $name, my $args) = $call.split('(', 2);
        my $proto   := ::("&$name");
        my $capture := $args.defined
          ?? ('\(' ~ $args).EVAL
          !! \();
        do-sourcery $proto.candidates, $capture;
    }
}

=begin pod

=head1 NAME

sourcery - turn a sub / method call into file(s) / linenumbers(s)

=head1 SYNOPSIS

=begin code :lang<raku>

use sourcery;

.say for sourcery '"42".Int';   # show where a Str gets converted to Int

.say for sourcery 'say "foo"';  # show where strings are being said

use Edit::Files;

edit-files sourcery '42.base("beer")';  # go see where this easter egg lives

=end code

=head1 DESCRIPTION

The sourcery module exports a single subroutine called C<sourcery>.  It
converts a piece of code consisting of a subroutine or method call to zero
or more file / line-number pairs.  Which can then be displayed or used
as input to go inspect / edit those files.

Inspired by Zoffix's L<CoreHackers::Sourcery|https://raku.land/zef:raku-community-modules/CoreHackers::Sourcery>
module, with the following differences:

=item generates local file locations instead of URLs
=item not limited to core code, could be used on any loaded codebase

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
