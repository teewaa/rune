package main

import "core:fmt"
import os "core:os/os2"
import "core:strings"

@(private="file")
OUTPUT_FLAG :: "o"

process_new :: proc(args: Parsed_Args) -> Error {
    build_mode_err := validate_build_mode(args)
    if build_mode_err != nil { return build_mode_err }

    arch_raw := fmt.aprintf("%s_%s", ODIN_OS, ODIN_ARCH)
    arch := strings.to_lower(arch_raw)
    delete(arch_raw)
    defer delete(arch)

    target_name, target_err := parse_output_flag(args.flags)
    if target_err != nil {
        return target_err
    }

    schema := SchemaJson {
        schema = SCHEMA_PATH,
        default_profile = "default",
        profiles = {
            {
                name = "default",
                target = target_name,
                output = "bin/{config}/{arch}",
                arch = arch,
                entry = "src",
                build_mode = args.positionals[1],
            }
        }
    }

    write_err := write_root_file(schema)
    if write_err != nil { return write_err }

    return nil
}

@(private="file")
parse_output_flag :: proc(flags: map[string]string) -> (string, Error) {
    if OUTPUT_FLAG in flags {
        if flags[OUTPUT_FLAG] == DEFAULT_FLAG_VAL {
            fmt.eprintfln("Output name is invalid. Make sure to specific it using <-o:target_name>")
            return "", .INVALID_OUTPUT_VALUE
        }
        return flags[OUTPUT_FLAG], nil
    }

    full_path, get_dir_err := os.get_working_directory(context.allocator)
    defer delete(full_path)
    if get_dir_err != nil {
        fmt.eprintln("Failed to get active directory")
        return "", get_dir_err
    }

    dirs: []string
    defer delete(dirs)

    when ODIN_OS == .Windows {
        dirs = strings.split(full_path, "\\")
    } else {
        dirs = strings.split(full_path, "/")
    }

    return len(dirs) > 1 ? dirs[len(dirs) - 1] : dirs[0], nil
}

@(private="file")
validate_build_mode :: proc(args: Parsed_Args) -> Error {
    if len(args.positionals) < 2 {
        fmt.eprintln("Please specify build mode by running \"rune new [build_mode] <-o:target_name>\"")
        fmt.eprintln("Valid build modes are:")
        for type in project_types {
            fmt.eprintfln("\t%s", type)
        }
        return .NO_BUILD_MODE_SPECIFIED
    }

    for type in project_types {
        if args.positionals[1] == type {
            return nil
        }
    }

    fmt.eprintfln("%s is not supported as a build mode. Select from:", args.positionals[1])
    for type in project_types {
        fmt.eprintfln("\t%s", type)
    }

    return .INVALID_BUILD_MODE
}