import getopts
import os

fn main() {
    // Declare a new command line parser
    mut ncl := getopts.new_cmd_line() or {
        println(err)
        exit(8)
    }

    // Add an option that has both a long form and a short form. The short
    // form is -p and the long is --print. An option is not mandatory2yy
    ncl.add_option('s', 'skip', 'x', 'Option with long and short forms') or {
        println(err)
        exit(8)
    }

    // Add an option that has just a short form. pass it into your program
    // with -x. Again, you do not have to pass this argument to your
    // program
    ncl.add_option('x', '', 'x', 'Option with just a short form') or {
        println(err)
        exit(8)
    }

    // Add an option that has just a long form. pass it into your program
    // with --filename
    ncl.add_option('', 'filename', 'MANIFEST_FILE',
            'Option with just a long form') or {
        println(err)
        exit(8)
    }

    // Add a flag that has both a long and short form. Flags are switches, so
    // they expect no values, and they are also optional. You check if they
    // have been passed with the is_option_set() function
    ncl.add_flag('d', 'flag-d', 'a simple flag') or {
        println(err)
        exit(8)
    }

    // An argument takes a value, and is mandatory. The parse() function will
    // throw an error if you don't provide a value
    ncl.add_argument('foo', 'a simple argument') or {
        println(err)
        exit(8)
    }
    ncl.parse(os.args) or {
        println(err)
        exit(8)
    }

    if ncl.is_option_set('skip') {
        val := ncl.option_value('skip')
        println('You set option -s/--skip: $val')
    }

    if ncl.is_option_set('x') {
        println('You set option value -x: ${ncl.option_value('x')} ')
    }

    println(ncl.is_option_set('d'))
    println(ncl.is_option_set('flag-d'))

    println('You set the argument to: ${ncl.argument_value('foo')} ')
}
