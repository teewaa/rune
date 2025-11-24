package main

import "core:fmt"

process_script :: proc(args: Parsed_Args, schema: Schema) -> Error {
    script: string
    for key in schema.scripts {
        if key == args.positionals[0] {
            script = schema.scripts[key]
            break
        }
    }

    if script == "" {
        fmt.eprintfln("Script %s is not listed in rune.json", args.positionals[0])
        return .INVALID_SCRIPT
    }

    script_err := execute_script_with_logs(script)
    if script_err != nil { return script_err }

    return nil
}