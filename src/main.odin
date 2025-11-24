package main

import "core:fmt"
_ :: fmt
import "core:mem"
_ :: mem
import os "core:os/os2"
import "core:time"

@(private="file")
VERSION     :: #config(VERSION, "dev")
@(private="file")
VERBOSE_S   :: "v"
@(private="file")
VERBOSE     :: "verbose"

main :: proc() {
    when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

    start_time := time.now()

    if len(os.args) < 2 {
        print_help()
        return
    }

    args := parse_args(os.args)
    defer destroy_args(&args)
    
    if HELP_SHORT in args.flags || HELP in args.flags {
        print_help()
        return
    }

    if args.positionals[0] == "version" {
        log_info(VERSION)
        return
    }

    cmd := args.positionals[0]
    schema, schema_err := get_rune_schema()
    if schema_err != nil && cmd != NEW {
        fmt.eprintln("Missing rune.json")
        return
    }
    defer destroy_schema(schema)

    err: Error
    switch cmd {
        case BUILD:
            err = process_build(args, schema, is_verbose(args.flags))
        case NEW:
            err = process_new(args)
        case RUN:
            err = process_run(args, schema, is_verbose(args.flags))
        case TEST:
            err = process_test(args, schema, is_verbose(args.flags))
        case:
            err = process_script(args, schema)
    }

    total_time := time.duration_seconds(time.since(start_time))
    if err != nil {
        fmt.println()
        fmt.eprintfln("Failed in: %.3f seconds with error %s", total_time, err)
    } else {
        fmt.printfln("Completed in: %.3f seconds", total_time)
    }
}

@(private="file")
is_verbose :: proc(args: map[string]string) -> bool {
    return VERBOSE_S in args || VERBOSE in args
}