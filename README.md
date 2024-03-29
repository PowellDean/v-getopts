# Getopts

## Introduction

Getopts is a simple CLI argument parser written in [V](https://vlang.io). It
handles options (with optional default values) and arguments.
This is a shameless ripoff of
[go-cmdline](https://github.com/galdor/go-cmdline/blob/master/cmdline.go). We
give thanks to the author of that Go module.

## Options, Arguments, and Flags

The module accepts options, arguments and flags. Arguments are positional,
and always follow the options. Arguments are also mandatory -- they must
be passed into your program or an error will be thrown.

Options, as the name implies, are not mandatory and must always be passed in
before any arguments. Options always expect a corresponding value to be passed.
Failure to include a value will result in an error condition.

Flags do not accept any values and are also optional.

Options and flags both accept more traditional short forms, which are preceded
by a single dash (-) and consist of a single letter. They also each accept a
long name, which are preceded by double dashes (--) and consist of a word (any
token surrounded by whitespace). The short form and long forms for any given
option or flag do not have to start with the same letter. Examples below!

## Caveats

On the command line, each option *must* be separated from its value with at
least one whitespace character, and not an equals sign (=). For example:

**Will Work**

my_program --skip 3

**Won't Work**

my_program --skip=3

**Won't Work**

my_program -s3

## General Usage

Here is a typical (short) program:

```v
import os
import getopts

fn main() {
    mut ncl := getopts.new_cmd_line()
    ncl.add_option('s', 'skip', 'x', 'display the value') or {
        println(err)
        exit(8)
    }

    ncl.parse(os.args) or {
        println(err)
        exit(8)
    }

    if ncl.is_option_set('skip') {
        val := ncl.option_value('s')
        println('You set option -s/--skip: $val')
    }
}
```

Afer compiling, invoke the program like this:

```bash
$ my_program -s 4
```

Or like this:

```bash
$ my_program --skip 4
```

In either case, the output to stdout would be:

```
You set option -s/--skip: 4
```

The options -h and --help are automatically handled, so if you were to invoke
the above program like this:

```bash
$ my_program --help
```

The corresponding output to stdout would be:

```
Usage: /full/path/to/my_program OPTIONS

OPTIONS

-h, --help      print help and exit
-s, --skip <x>  Option with long and short forms
```

## Handling Commands

Handling commands is a little bit clunky at the moment, due to optional return
values from some functions having to be processed. We may try to clean this up,
but as of now, the module _does_ handle command processing.

If you need to process a command like this:

```bash
my_program add -p FOO
```

The short-ish program below should do the trick:

```v
import getopts
import os

fn main() {
    mut ncl := getopts.new_cmd_line() or {
        println(err)
        exit(8)
    }

    ncl.add_command("add", "Add something") or {
        println(err)
        exit(8)
    }

    ncl.parse(os.args) or {
        println(err)
        exit(8)
    }

    cmd_name := ncl.command_name() or {
        println(err)
        exit(8)
    }

    a := ncl.command_name_and_arguments() or {
        println(err)
        exit(8)
    }

    if cmd_name == 'add' {
        run_command(a)
    }
}

fn run_command(these_args []string) {
    mut nc2 := getopts.new_cmd_line() or {
        println(err)
        exit(8)
    }

    nc2.add_option('p', 'program', 'pgmname','name of program to run') or {
        println(err)
        exit(8)
    }

    nc2.parse(these_args) or {
        println(err)
        exit(8)
    }

    if nc2.is_option_set('p') {
        val := nc2.option_value('p')
        println('For command add, you set option p to value: ${val}')
    }
}
```


After compilation, running the program as shown above would produce this
result:

```
For command add, you set option p to value: FOO
```

## Required Compiler Version

The module and example programs were built with __V 0.2.4 47313cb__. We
cannot guarantee successful compilation with earlier versions.

## Contact

If you have ideas, questions, or criticisms, email me at
PowellDean@gmail.com

## Contributing??

Have a contribution? Pull requests are **ALWAYS** welcome!
