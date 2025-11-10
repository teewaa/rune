package cmds

import "core:fmt"
import "core:strings"
import "rune:utils"

// process_new handles the `rune new [build_mode] [target]` command.
//
// It validates the input arguments, generates a default `rune.json` schema
// with a basic profile configuration, and writes it to the root of the project.
//
// Parameters:
// - sys:  System interface for interacting with the file system.
// - args: Command-line arguments passed after `rune new`.
//
// Returns:
// - A success message if the file is created successfully.
// - An error message if validation fails or file writing encounters an issue.
process_new :: proc(sys: utils.System, args: []string) -> (string, string) {
    build_mode_err := validate_build_mode(args)
    if build_mode_err != "" {
        return "", build_mode_err
    }

    arch_raw := fmt.aprintf("%s_%s", ODIN_OS, ODIN_ARCH)
    arch := strings.to_lower(arch_raw)
    delete(arch_raw)
    defer delete(arch)

    target_name, target_err := parse_output_flag(sys, args)
    if target_err != "" {
        return "", target_err
    }

    schema := utils.SchemaJson {
        schema = "https://raw.githubusercontent.com/teewaa/rune/refs/heads/main/misc/rune.0.5.x.json",
        default_profile = "default",
        profiles = {
            {
                name = "default",
                target = target_name,
                output = "bin/{config}/{arch}",
                arch = arch,
                entry = "src",
                build_mode = args[1],
            }
        }
    }

    write_err := utils.write_root_file(sys, schema)
    if write_err != "" {
        return "", write_err
    }

    return strings.clone("Done"), ""
}

// parse_output_flag retrieves the target name of the project from `rune new -o:<target_name>`.
//
// It looks for the -o:<target_name> flag and if it doesn't exists, returns the directory name
// as targeted output name.
//
// Parameters:
// - sys:  System interface for interacting with the file system.
// - args: Command-line arguments from the CLI call.
//
// Returns:
// - The targeted output name
@(private="file")
parse_output_flag :: proc(sys: utils.System, args: []string) -> (string, string) {
    for arg in args {
        if strings.starts_with(arg, "-o") {
            output_arr := strings.split(arg, ":")
            defer delete(output_arr)
            if len(output_arr) != 2 {
                return "", fmt.aprintf("Invalid output flag %s. Make sure it is formatted -o:<target_name>", arg)
            }

            return output_arr[1], ""
        }
    }

    full_path := sys.fs.get_current_directory()

    dirs: []string
    defer delete(dirs)

    when ODIN_OS == .Windows {
        dirs = strings.split(full_path, "\\")
    } else {
        dirs = strings.split(full_path, "/")
    }

    return len(dirs) > 1 ? dirs[len(dirs) - 1] : dirs[0], ""
}

// validate_build_mode ensures that a valid build mode is passed to `rune new`.
//
// If no build mode is provided or it's not among the supported types,
// it returns an appropriate error message with usage guidance.
//
// Parameters:
// - args: Command-line arguments from the CLI call.
//
// Returns:
// - An error message string if validation fails; empty string if valid.
@(private="file")
validate_build_mode :: proc(args: []string) -> (err: string) {
    if len(args) < 2 {
        err = strings.clone("Please specify build mode by running \"rune new [build_mode] [target_name]\"\nValid build modes:")
        for type in utils.project_types {
            err = strings.join({err, fmt.aprintf("\t%s", type)}, "\n")
        }

        return err
    }

    for type in utils.project_types {
        if args[1] == type {
            return ""
        }
    }

    return fmt.aprintf("%s is not supported as a build mode", args[1])
}
