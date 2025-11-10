package cmds

import "core:fmt"
import "core:strings"
import "rune:utils"

// BuildData holds build-specific metadata such as entry file, output path,
// compiler flags, and architecture. This struct can be reused for tasks that 
// need to manage build configuration.
BuildData :: struct {
    entry:  string,             // Entry point file for the build
    output: string,             // Output file path for the built binary
    flags:  [dynamic]string,    // Additional flags to pass to the compiler
    arch:   string,             // Target architecture for the build (e.g., "x86_64")
}

// process_build handles the `rune build [profile?]` command.
//
// It uses the provided `args` to determine which profile to build.
// If no profile is explicitly provided, it uses the default one from the schema.
// The selected profile is then passed to `utils.process_profile` for actual compilation.
//
// Parameters:
// - sys:    The system abstraction used to interact with the OS or shell.
// - args:   Command-line arguments passed to `rune build`.
// - schema: Parsed rune.json configuration containing profiles and settings.
//
// Returns:
// - success: A success message string, if the build completes successfully.
// - err:     An error message string, if something goes wrong.
process_build :: proc(sys: utils.System, args: []string, schema: utils.Schema) -> (success: string, err: string) {
    if schema.default_profile == "" && len(args) < 2 {
        err = strings.clone("No default profile was set. Define one or rerun using `rune build [profile]`")
        return "", err
    }

    profile_name := should_get_profile_name(args, sys.verbose) ? args[1] : schema.default_profile

    profile, profile_ok := utils.get_profile(schema, profile_name)
    if !profile_ok {
        err = fmt.aprintf("Failed to find \"%s\" in the list of profiles", profile_name)
        return "", err
    }

    err = utils.process_profile(sys, profile, schema, args[0])
    if err != "" {
        return "", err
    }

    return strings.clone("Build completed"), ""
}

should_get_profile_name :: proc(args: []string, is_verbose: bool) -> bool {
    return len(args) > 1 && !is_verbose || len(args) > 2 && is_verbose
}
