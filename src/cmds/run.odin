package cmds

import "core:fmt"
import "core:strings"
import "rune:utils"

// process_run handles the `rune run [profile | script]` command.
//
// It determines whether to run a build profile or a named script defined in `rune.json`.
// If a profile is matched, it delegates to `process_build` to compile and execute it.
// Otherwise, it attempts to run a custom script from the `scripts` map in the schema.
//
// Parameters:
// - sys:    System abstraction for shell and file operations.
// - args:   Command-line arguments passed to `rune run`.
// - schema: Parsed schema from `rune.json` containing profiles, configs, and scripts.
//
// Returns:
// - success: A message indicating a successful build or script execution.
// - err:     An error string if execution fails at any stage.
process_run :: proc(sys: utils.System, args: []string, schema: utils.Schema) -> (success: string, err: string) {
    if schema.default_profile == "" && len(args) < 2 {
        return "", strings.clone("Run script not found")
    }

    if schema.default_profile != "" && len(args) < 2 {
        build_success, build_err := process_build(sys, args, schema)
        return build_success, build_err
    }

    profile: string
    if schema.default_profile != "" && len(args) >= 2 {
        for p in schema.profiles {
            if p.name == args[1] {
                profile = p.name
                break
            }
        }
    }

    if profile != "" {
        build_success, build_err := process_build(sys, args, schema)
        return build_success, build_err
    }

    return "", fmt.aprintf("Profile %s does not exist", args[1])
}
