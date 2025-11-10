#+feature dynamic-literals
package main

import "core:fmt"
import "core:os"
import "core:os/os2"
import "core:strings"
import "core:time"
import "rune:cmds"
import "rune:logger"
import "rune:utils"


VERSION :: #config(VERSION, "dev")


main :: proc() {
    if len(os2.args) < 2 {
        cmds.print_help()
        return
    }

    start_time := time.now()

    sys := utils.System {
        fs = {
            exists = os2.exists,
            make_directory = os2.make_directory,
            copy_file = os2.copy_file,
            read_dir = os2.read_dir,
            open = os2.open,
            close = os2.close,
            is_dir = os2.is_dir,
            read_entire_file_from_path = os2.read_entire_file_from_path,
            write_entire_file = os2.write_entire_file,
            get_current_directory = os.get_current_directory,
        },
        process = {
            pipe = os2.pipe,
            process_close = os2.process_close,
            process_start = os2.process_start,
            process_wait = os2.process_wait
        },
        verbose = is_verbose(os2.args),
    }

    if os2.args[1] == "version" {
        logger.info(VERSION)
        return
    }

    schema, schema_err := utils.read_root_file(sys)
    defer delete(schema.scripts)
    cmd := strings.to_lower(os2.args[1])

    if schema_err != "" && cmd != "new" {
        logger.error(schema_err)
        return;
    }

    err: string
    success: string

    defer delete(err)
    defer delete(success)

    switch cmd {
        case "-h", "--help":
            cmds.print_help()
        case "build":
            success, err = cmds.process_build(sys, os2.args[1:], schema)
        case "run":
            success, err = cmds.process_run(sys, os2.args[1:], schema)
        case "test":
            err = cmds.process_test(sys, os2.args[1:], schema)
        case "new":
            success, err = cmds.process_new(sys, os2.args[1:])
        case:
            success, err = cmds.process_script(sys, os2.args[1:], schema)
    }

    if err != ""  {
        logger.error(err)
    }

    if success != "" && cmd != "run" {
        total_time := time.duration_seconds(time.since(start_time))
        msg := fmt.aprintf("%s: %.3f seconds", success, total_time)
        logger.success(msg)
        delete(msg)
    }
}

is_verbose :: proc(args: []string) -> bool {
    for i in 0..<len(args) {
        if args[i] == "-v" || args[i] == "--verbose" {
            return true
        }
    }
    
    return false
}