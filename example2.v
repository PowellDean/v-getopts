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
