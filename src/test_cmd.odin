package main

import "core:fmt"
import "core:strings"

@(private="file")
FILE_FLAG       :: "f"
@(private="file")
PACKAGE_FLAG    :: "p"
@(private="file")
TEST_FLAG       :: "t"

process_test :: proc(args: Parsed_Args, schema: Schema, is_verbose: bool) -> Error {
    profile_name := len(args.positionals) > 1 ? args.positionals[1] : schema.default_test_profile
    profile, profile_err := get_profile(schema, profile_name)
    if profile_err != nil { return profile_err }

    file_parse_err := parse_file_flag(args.flags, &profile)
    if file_parse_err != nil { return file_parse_err }

    package_parse_err := parse_package_flag(args.flags, &profile)
    if package_parse_err != nil { return package_parse_err }

    test_parse_err := parse_test_flag(args.flags, &profile)
    if test_parse_err != nil { return test_parse_err }

    defer {
        for flag in profile.flags {
            delete(flag)
        }
        delete(profile.flags)
    }

    process_err := process_profile(profile, schema, "test", is_verbose)
    if process_err != nil {  return process_err }

    return nil
}

@(private="file")
parse_file_flag :: proc(flags: map[string]string, profile: ^SchemaProfile) -> Error {
    if FILE_FLAG in flags {
        if flags[FILE_FLAG] == DEFAULT_FLAG_VAL {
            fmt.eprintfln("Invalid file name. Make sure it is formatted -f:<file_name>")
            return .INVALID_FILE_FLAG_VALUE
        }

        profile.entry = flags[FILE_FLAG]
        _, append_err := append(&profile.flags, strings.clone("-file"))
        if append_err != nil {
            fmt.eprintln("Failed to append flag")
            return append_err
        }
    }

    return nil
}

@(private="file")
parse_package_flag :: proc(flags: map[string]string, profile: ^SchemaProfile) -> Error {
    if PACKAGE_FLAG in flags {
        if flags[PACKAGE_FLAG] == DEFAULT_FLAG_VAL {
            fmt.eprintfln("Invalid package name. Make sure it is formatted -p:<package_name>")
            return .INVALID_PACKAGE_FLAG_VALUE
        }

        profile.entry = flags[PACKAGE_FLAG]
    }

    return nil
}

@(private="file")
parse_test_flag :: proc(flags: map[string]string, profile: ^SchemaProfile) -> Error {
    if TEST_FLAG in flags {
        if flags[TEST_FLAG] == DEFAULT_FLAG_VAL {
            fmt.eprintln("Invalid test name. Make sure it is formatted -t:<test_name>")
            return .INVALID_TEST_FLAG_VALUE
        }

        new_flag := fmt.aprintf("-define:ODIN_TEST_NAMES=%s", flags[TEST_FLAG])
        defer delete(new_flag)
        _, append_err := append(&profile.flags, strings.clone(new_flag))
        if append_err != nil {
            fmt.eprintln("Failed to append flag")
            return append_err
        }
    }

    return nil
}
