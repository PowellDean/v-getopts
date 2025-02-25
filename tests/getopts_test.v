import getopts

fn init_option_tests() !getopts.Cmd_line {
    mut ncl := getopts.new_cmd_line() or {
        println('Error initializing getopts: ${err}')
        return err
    }

    ncl.add_option('s', 'skip', '', 'Number of lines to skip') or {
        println('Error adding option')
        return err
    }

    return ncl
}

fn run_option_tests() {
    mut ncl := init_option_tests() or {
        println(err)
        exit(8)
    }

    ncl.parse(['getopts_test', '--skip', '3']) or {
        println('Error parsing args: ${err}')
        exit(8)
    }

    assert ncl.is_option_set('skip') == true
    assert ncl.is_option_set('s') == true
    assert ncl.option_value('s') == '3'
    assert ncl.option_value('skip') == '3'
}

fn test_main() {
    run_option_tests()
}
