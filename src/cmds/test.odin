package cmds

import "core:fmt"
import "core:strings"
import "rune:utils"

// process_test handles the `rune test [profile?] [-t:test_name] [-f:file_name]` command.
//
// This function runs tests for the project. It checks if a valid test profile is provided,
// either via the command-line arguments or from the default configuration in `rune.json`.
// It also processes additional flags like `-t:test_name` to run specific tests and `-f:file_name`
// to target specific test files.
//
// Parameters:
// - sys:    System abstraction for file and shell operations.
// - args:   Command-line arguments passed to `rune test`.
// - schema: Parsed schema from `rune.json`, including profiles and configurations.
//
// Returns:
// - A success message or an error message if validation or execution fails.
process_test :: proc(sys: utils.System, args: []string, schema: utils.Schema) -> string {
    profile_name := len(args) > 1 && !strings.starts_with(args[1], "-") ? args[1] : schema.default_test_profile
    profile, profile_ok := utils.get_profile(schema, profile_name)
    if !profile_ok {
        if profile_name != "" {
            return fmt.aprintf("Profile %s does not exists", profile_name)
        }
        
        return strings.clone("No default test profile is defined")
    }

    if len(args) >= 2 {
        file_parse_err := parse_file_flag(args[1:], &profile)
        if file_parse_err != "" {
            return file_parse_err
        }

        package_parse_err := parse_package_flag(args[1:], &profile)
        if package_parse_err != "" {
            return package_parse_err
        }

        test_parse_err := parse_test_flag(args[1:], &profile)
        if test_parse_err != "" {
            return test_parse_err
        }
    }

    defer {
        for flag in profile.flags {
            delete(flag)
        }
        delete(profile.flags)
    }

    err := utils.process_profile(sys, profile, schema, "test")
    if err != "" {
        return err
    }

    return ""
}

// parse_file_flag processes the `-f:file_name` flag, which specifies a particular test file
// to run.
//
// Parameters:
// - arg: The `-f` argument passed in the command line.
// - profile: The profile to modify with the file information.
//
// Returns:
// - An error message if the flag is invalid or incorrectly formatted.
@(private="file")
parse_file_flag :: proc(args: []string, profile: ^utils.SchemaProfile) -> (string) {
    for arg in args {
        if strings.starts_with(arg, "-f") {
            args_arr := strings.split(arg, ":")
            defer delete(args_arr)
            if len(args_arr) != 2 {
                return fmt.aprintf("Invalid file flag %s. Make sure it is formatted -f:<file_name>", arg)
            }

            profile.entry = args_arr[1]
            _, append_err := append(&profile.flags, strings.clone("-file"))
            if append_err != nil {
                return fmt.aprintf("Failed to append: %s", append_err)
            }
        }
    }

    return ""
}

// parse_package_flag processes the `-p:<package_name>` flag, which specifies a particular test package
// to run.
//
// Parameters:
// - arg: The `-p` argument passed in the command line.
// - profile: The profile to modify with the file information.
//
// Returns:
// - An error message if the flag is invalid or incorrectly formatted.
@(private="file")
parse_package_flag :: proc(args: []string, profile: ^utils.SchemaProfile) -> (string) {
    for arg in args {
        if strings.starts_with(arg, "-p") {
            args_arr := strings.split(arg, ":")
            defer delete(args_arr)
            if len(args_arr) != 2 {
                return fmt.aprintf("Invalid package flag %s. Make sure it is formatted -p:<package_name>", arg)
            }

            profile.entry = args_arr[1]
        }
    }

    return ""
}

// parse_test_flag processes the `-t:test_name` flag, which specifies a particular test to run.
//
// Parameters:
// - arg: The `-t` argument passed in the command line.
// - profile: The profile to modify with the test name information.
//
// Returns:
// - An error message if the flag is invalid or incorrectly formatted.
@(private="file")
parse_test_flag :: proc(args: []string, profile: ^utils.SchemaProfile) -> (string) {
    for arg in args {
        if strings.starts_with(arg, "-t") {
            args_arr := strings.split(arg, ":")
            defer delete(args_arr)
            if len(args_arr) != 2 {
                return fmt.aprintf("Invalid test name flag %s. Make sure it is formatted -t:<test_name>", arg)
            }

            new_flag := fmt.aprintf("-define:ODIN_TEST_NAMES=%s", args_arr[1])
            defer delete(new_flag)
            _, append_err := append(&profile.flags, strings.clone(new_flag))
            if append_err != nil {
                return fmt.aprintf("Failed to append: %s", append_err)
            }
        }
    }

    return ""
}
