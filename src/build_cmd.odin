package main

import "core:fmt"

process_build :: proc(args: Parsed_Args, schema: Schema, is_verbose: bool) -> Error {
    if schema.default_profile == "" && len(args.positionals) < 2 {
        fmt.eprintln("No default profile was set. Define one or rerun using `rune build [profile]`")
        return .NO_DEFAULT_PROFILE
    }

    profile_name := should_get_profile_name(args) ? args.positionals[1] : schema.default_profile

    profile, profile_err := get_profile(schema, profile_name)
    if profile_err != nil { return profile_err }

    process_err := process_profile(profile, schema, args.positionals[0], is_verbose)
    if process_err != nil { return profile_err }

    return nil
}

@(private="file")
should_get_profile_name :: proc(args: Parsed_Args) -> bool {
    return len(args.positionals) > 1
}