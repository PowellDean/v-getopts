module getopts
// getopts is a module to parse command line options (with optional default
// values, arguments, and subcommands.

/*
Copyright © 2020-2021 Dean Powell <PowellDean@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished
to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

//import os

// https://github.com/galdor/go-cmdline/blob/master/cmdline.go

pub struct Opt {
    mut:
        short_name    string
        long_name     string
        value_string  string
        description   string
        default       string
        set           bool
        value         string
}

pub fn (o Opt) sort_key() (string) {
    if o.short_name != '' {
        return o.short_name
    }
    if o.long_name != '' {
        return o.long_name
    }

    return ''
}

pub struct Argument {
    mut:
        name             string
        description      string
        trailing         bool
        value            string
        trailing_values  []string
}

pub struct Command {
    mut:
        name             string
        description      string
}

pub struct Cmd_line {
    mut:
        options            map[string]Opt
        arguments          []Argument
        commands           map[string]Command
        command            string
        command_arguments  []string
        program_name       string
}

// new_cmd_line creates a new, initialized Cmd_line. Use this function instead
// of defining a Cmd_line yourself
pub fn new_cmd_line() ?Cmd_line {
    mut cloption := Cmd_line{}
    cloption.add_flag('h', 'help', 'print help and exit') or {
        return error(err)
    }

    return cloption
}

// add_argument adds a new, initialized Argument to the Cmd_line.
pub fn (mut cmd Cmd_line) add_argument(new_name string, desc string) ? {
    this_arg := Argument{
        name: new_name
        description: desc
    }

    cmd.new_argument(this_arg) or {
        return error(err)
    }
}

pub fn (mut cmd Cmd_line) add_command(cmd_name string, desc string) ? {
    if cmd.arguments.len == 0 {
        cmd.add_argument('command', 'the command to execute') or {
            return error(err)
        }
    } else {
        if cmd.arguments[0].name != "command" {
            return error('Cannot have both arguments and commands')
        }
    }

    new_command := Command{
        name: cmd_name,
        description: desc
    }

    cmd.commands[new_command.name] = new_command
}

// add_flag adds a new, initialized Opt to the Cmd_line. The Opt will be
// initialized with the short_name, long_name, and description. The
// value_string will be initialized to blank
pub fn (mut cmd Cmd_line) add_flag(short string, long string, desc string) ? {
    new_option := Opt{
        short_name: short,
        long_name: long,
        value_string: '',
        description: desc}

    cmd.new_option(new_option) or {
        println(err)
        return error('Could not add flag')
    }
}

pub fn (mut cmd Cmd_line) add_option(
                short string,
                long string,
                value string,
                desc string) ? {
    if short.len == 0 && long.len == 0 {
        return error('You must specify at least a short or long option name')
    }

    this_opt := Opt{
        short_name: short,
        long_name: long,
        value_string: value,
        description: desc}

    cmd.new_option(this_opt) or {
        return error(err)
    }
}

// argument_value returns the value assigned to the given argument at runtime.
// Arguments cannot be blank, so if after iterating through all arguments we
// don't find the argument name we're looking for, throw an error
pub fn (cmd Cmd_line) argument_value(arg_name string) ?string {
    mut return_string := ''
    for this_arg in cmd.arguments {
        if this_arg.name == arg_name {
            return_string = this_arg.value
        }
    }

    if return_string == '' {
        return error('unknown argument $arg_name')
    }

    return return_string
}

pub fn (cmd Cmd_line) command_name() ?string {
    if cmd.commands.len == 0 { return error('No command defined') }

    return cmd.command
}

pub fn (cmd Cmd_line) command_name_and_arguments() ?[]string {
    if cmd.commands.len == 0 { return error('No command defined') }

    mut out_strings := [cmd.command]
    out_strings << cmd.command_arguments
    return out_strings
}

pub fn (cmd Cmd_line) is_option_set(name string) bool {
    mut retval := false

    if name in cmd.options {
        this_option := cmd.options[name]
        retval = this_option.set
    }

    return retval
}

fn (mut cmd Cmd_line) new_argument(new_arg Argument) ? {
    if cmd.commands.len > 0 {
        return error('Cannot have both commands and arguments!')
    }

    if cmd.arguments.len > 0 {
        last := cmd.arguments[cmd.arguments.len - 1]
        if last.trailing {
            return error('Cannot add argument after trailing argument')
        }
    }

    cmd.arguments << new_arg
}

fn (mut cmd Cmd_line) new_option(new_option Opt) ? {
    if new_option.short_name != '' {
        if new_option.short_name.len != 1 {
            return error('option short names must be one character long')
        }
        cmd.options[new_option.short_name] = new_option
    }

    if new_option.long_name != '' {
        if new_option.long_name.len < 2 {
            return error('option long names must be at least 2 characters')
        }
        cmd.options[new_option.long_name] = new_option
    }
}

pub fn (cmd Cmd_line) option_value(name string) string {
    mut retval := ''
    if name in cmd.options {
        opt := cmd.options[name]
        if opt.set {
            retval = opt.value
        } else {
            retval = opt.default
        }
    } else {
        return 'unknown option'
    }
    return retval
}

pub fn (mut cmd Cmd_line) parse(args []string) ? {
    mut local_args := args.clone()
    if local_args.len == 0 {
        return error('empty argument array')
    }

    cmd.program_name = args[0]
    local_args = local_args[1..]

    for local_args.len > 0 {
        this_arg := local_args[0]
        if this_arg == '--' {
            local_args = local_args[1..]
            break
        }

        is_short := this_arg.len == 2 && this_arg[0] == 45 && this_arg[1] != 45
        is_long := this_arg.len > 2 && this_arg[0..2] == '--'

        if is_short || is_long {
            mut key := ''
            mut key1 := ''

            // in the 'Go' version, we don't need to explicitly set both keys
            // Not sure how that magic happens but it wasn't working here so I 
            // have to make sure we set both options correctly
            if is_short {
				key = this_arg[1..2]
                key1 = cmd.options[key].long_name
			}
            if is_long {
                key = this_arg[2..]
                key1 = cmd.options[key].short_name
            }

            if key in cmd.options {
            } else {
                return error('invalid option $key')
            }

            mut this_option := cmd.options[key]
            this_option.set = true

            if this_option.value_string == '' {
                local_args = local_args[1..]
                cmd.options[key] = this_option
                cmd.options[key1] = this_option
            } else {
                if local_args.len < 2 {
                    return error('Missing value for option $key')
                }
                this_option.value = local_args[1]
                local_args = local_args[2..]
                cmd.options[key] = this_option
                cmd.options[key1] = this_option
            }
        } else {
            // first argument
            break
        }
    }

    // Arguments
    if cmd.arguments.len > 0 && cmd.is_option_set("help") == false {
        mut last := cmd.arguments[cmd.arguments.len-1]
        mut min := cmd.arguments.len
        if last.trailing { min-- }
        if local_args.len < min { return error('Missing argument(s)') }

        for i := 0; i < min; i++ {
            cmd.arguments[i].value = local_args[i]
        }

        local_args = local_args[min..]

        if last.trailing {
            last.trailing_values = local_args
            local_args = local_args[local_args.len..]
        }
    }

    // Commands
    if cmd.commands.len > 0 {
        cmd.command = cmd.arguments[0].value
        cmd.command_arguments = local_args
    }

    help_me := cmd.is_option_set("help")
    if help_me {
        cmd.print_usage()
        exit(0)
    } else {
        if cmd.commands.len > 0 {
            found := cmd.command in cmd.commands
            if found {
            } else {
                return error('Unknown command $cmd.command')
            }
        } else if local_args.len > 0 {
            return error('Invalid extra argument(s)')
        }
    }
}

pub fn (cmd Cmd_line) print_usage() {
    print("Usage: ${cmd.program_name} OPTIONS")
    if cmd.arguments.len > 0 {
        for an_arg in cmd.arguments {
            if an_arg.trailing {
                print(" [${an_arg.name} ...]")
            } else {
                print(" <${an_arg.name}>")
            }
        }
    }
    print("\n\n")

    // Let's calculate the longest argument line
    mut max_width := 0
    mut print_options := []string{}
    mut print_commands := []string{}

    for _, an_opt in cmd.options {
        mut local_width := 0
        local_width += an_opt.short_name.len + 1
        local_width += an_opt.long_name.len + 4
        local_width += an_opt.value_string.len + 5

        if an_opt.short_name.len > 0 {
            if an_opt.short_name in print_options {
            } else {
                print_options << an_opt.short_name
            }
        } else {
            if an_opt.long_name in print_options {
            } else {
                print_options << an_opt.long_name
            }
        }

        if local_width > max_width { max_width = local_width }
    }

    if cmd.commands.len > 0 {
        for c_name, _ in cmd.commands {
            print_commands << c_name
            if c_name.len > max_width { max_width = c_name.len }
        }
    } else if cmd.arguments.len > 0 {
        for an_argument in cmd.arguments {
            if an_argument.name.len > max_width { max_width = an_argument.name.len }
        }
    }

    // Sort the options
    print_options.sort()
    if max_width > 0 {
        println('OPTIONS\n')

        for this_opt in print_options {
            an_opt := cmd.options[this_opt]
            mut buffer := ''
            if an_opt.short_name != '' { buffer += '-${an_opt.short_name }' }
            if an_opt.long_name != '' {
                if buffer.len > 0 { buffer += ', ' }
                buffer += '--${an_opt.long_name}'
            }
            if an_opt.value_string != '' {
                buffer += ' <$an_opt.value_string>'
            }
            if an_opt.description != '' {
                if buffer.len < max_width {
                    for _ in buffer.len .. max_width {
                        buffer += ' '
                    }
                }
                buffer += '$an_opt.description'
            }

            println(buffer)
        }
    }

    if cmd.commands.len > 0 {
        print_commands.sort()
        println('\n\nCOMMANDS\n')

        for _, a_command in cmd.commands {
            mut buffer := right_pad(a_command.name, max_width)
            buffer += a_command.description
            println(buffer)
        }
    } else if cmd.arguments.len > 0 {
        println('\n\nARGUMENTS\n')

        for an_arg in cmd.arguments {
            mut buffer := right_pad(an_arg.name, max_width)
            buffer += an_arg.description
            println(buffer)
        }
    }
}

pub fn (cmd Cmd_line) set_option_default(name string, new_value string) {
    found := name in cmd.options
    mut this_opt := Opt{}
    if found {
        this_opt = cmd.options[name]
    }

    if this_opt.value_string == '' {
        println('Flags cannot have a default value!')
        return
    }

    this_opt.default = new_value
}

fn right_pad(init_value string, max_size int) string {
    mut new_buffer := init_value

    for _ in new_buffer.len .. max_size {
        new_buffer += ' '
    }

    return new_buffer
}
