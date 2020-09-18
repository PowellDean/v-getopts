# Getopts

## Introduction

Getopts is a simple CLI argument parser written in [V](https://vlang.io). It
handles options (with optional default values) and arguments.
This is a shameless ripoff of
[go-cmdline](https://github.com/galdor/go-cmdline/blob/master/cmdline.go)

## Usage

Here is a typical (short) program:

```v
import getopts

fn main() {
    mut ncl := getopts.new_cmd_line()
    ncl.add_option('p', 'print', 'x', 'display the value') or {
        println(err)
        exit(8)
    }
```

The options -h and --help are automatically handled.

## Contact

If you have ideas, questions, or (constructive) criticisms, email me at
PowellDean@gmail.com
