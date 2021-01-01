import getopts
import os

fn main() {
    mut ncl := getopts.new_cmd_line()
    ncl.add_command("add", "Add an entity to something")
    ncl.add_command("list", "List all current entries")
    ncl.parse(os.args) or {
        println(err)
        exit(8)
    }
    _ := ncl.command_name() or {
        println(err)
        exit(8)
    }
    a := ncl.command_name_and_arguments() or {
        println(err)
        exit(8)
    }
    run_command(a)
}

fn run_command(args []string) {
    mut nc2 := getopts.new_cmd_line()
    nc2.add_argument('program', 'a program name')
    nc2.parse(args)
	av := nc2.argument_value('program') or {
		println(err)
		exit(8)
	}
	println(av)
}
