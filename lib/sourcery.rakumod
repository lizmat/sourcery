my sub sourcery(Str:D $call, :$defined) {

    my sub invocant-capture(Str:D $invocant, Str:D $args) {
        ($args
          ?? '\(' ~ $invocant ~ ', ' ~ $args ~ ')'
          !! '\(' ~ $invocant ~ ')'
        ).EVAL
    }

    my sub do-sourcery(@blocks, $capture) {
        my $path := $*EXECUTABLE.parent.parent.parent.absolute ~ $*SPEC.dir-sep;
        @blocks.map(-> $block {
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
        }).unique
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

# vim: expandtab shiftwidth=4
