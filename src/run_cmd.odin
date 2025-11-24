package main

process_run :: proc(args: Parsed_Args, schema: Schema, is_verbose: bool) -> Error {
    if schema.default_profile == "" && len(args.positionals) < 2 {
        return .SCRIPT_NOT_FOUND
    }

    if schema.default_profile != "" && len(args.positionals) < 2 {
        build_err := process_build(args, schema, is_verbose)
        return build_err
    }

    profile: string
    if schema.default_profile != "" && len(args.positionals) >= 2 {
        for p in schema.profiles {
            if p.name == args.positionals[1] {
                profile = p.name
                break
            }
        }
    }

    if profile != "" {
        build_err := process_build(args, schema, is_verbose)
        return build_err
    }

    return .INVALID_RUNE_PROFILE
}
