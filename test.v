import getopts
import os

fn main() {
    /*
    mut ncl := getopts.new_cmd_line()
    ncl.add_option('p', 'print', 'x', 'display the value') or {
        println(err)
        exit(8)
    }
    ncl.add_option('x', '', 'x', 'display the value') or {
        println(err)
        exit(8)
    }
    ncl.add_option('', 'manifest', 'MANIFEST_FILE',
			'Alternate manifest file name') or {
        println(err)
        exit(8)
    }
    ncl.add_flag('d', 'flag-d', 'a simple flag')
    ncl.add_argument('foo', 'a simple argument')
    ncl.parse(os.args) or {
        println(err)
        exit(8)
    }

    //println(ncl.is_option_set('print'))
    //println(ncl.is_option_set('help'))
	if ncl.is_option_set('print') {
        println(ncl.option_value('print'))
	}

	if ncl.is_option_set('x') {
        println(ncl.option_value('x'))
	}

    println(ncl.is_option_set('d'))
    println(ncl.is_option_set('flag-d'))
   */
    mut ncl := getopts.new_cmd_line()
    ncl.add_command("add", "Add an entity to something")
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
    println('-------parse again')
    nc2.parse(args)
	av := nc2.argument_value('program') or {
		println(err)
		exit(8)
	}
	println(av)
}
