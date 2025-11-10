package utils

import "core:fmt"
import "core:strings"

// Retrieves the profile with the specified name from the schema.
//
// Parameters:
// - schema: The schema containing the profiles.
// - name: The name of the profile to retrieve.
//
// Returns:
// - SchemaProfile: The profile with the given name.
// - bool: A flag indicating whether the profile was found.
get_profile :: proc(schema: Schema, name: string) -> (SchemaProfile, bool) {
    for p in schema.profiles {
        if p.name == name {
            return p, true
        }
    }

    return {}, false
}

// Processes a profile by parsing the output, creating necessary directories,
// and executing the build command with the specified profile.
//
// Parameters:
// - sys: The system interface used for file operations.
// - profile: The profile containing configuration settings for processing.
// - schema: The schema containing additional configuration and scripts.
// - cmd: The build command to execute (e.g., "build").
//
// Returns:
// - string: An error message if any issue occurs during processing, or an empty string on success.
process_profile:: proc(
    sys: System,
    profile: SchemaProfile,
    schema: Schema,
    cmd: string
) -> string {

    output := parse_output(profile, cmd)
    defer delete(output)

    output_err := create_output(sys, output)
    if output_err != "" {
        return output_err
    }
    
    ext, ext_ok := get_extension(profile.arch, profile.build_mode)
    if !ext_ok {
        return fmt.aprintf("Failed to get extension for %s", profile.arch)
    }

    output_w_target, _ := strings.concatenate({output, profile.target, ext})
    defer delete(output_w_target)

    err := process_odin_cmd(sys, profile, schema.scripts, output_w_target, cmd)
    if err != "" {
        return err
    }

    return ""
}

// Parses the output directory and filename template based on the profile and schema configuration.
//
// Parameters:
// - configs: The configuration settings for output.
// - profile: The profile containing specific values to be used in the output template.
// - cmd:     The command that is passed to process the profile.
//
// Returns:
// - string: The parsed output path, with placeholders like "{config}", "{arch}", and "{profile}" replaced.
@(private="file")
parse_output :: proc(profile: SchemaProfile, cmd: string) -> string {
    is_debug := check_debug(profile.flags)

    output, _ := strings.replace(profile.output, "{config}", is_debug ? "debug" : "release", -1)
    output, _ = strings.replace(output, "{arch}", profile.arch, -1)
    output, _ = strings.replace(output, "{profile}", profile.name, -1)
    
    if len(output) > 1 && output[len(output)-1] != '/' {
        output = strings.concatenate({output, "/"})
    }

    return output
}

// Checks if the "-debug" flag is present in the list of profile flags.
//
// Parameters:
// - flags: The list of flags in the profile.
//
// Returns:
// - bool: `true` if the "-debug" flag is present, otherwise `false`.
@(private="file")
check_debug :: proc(flags: [dynamic]string) -> bool {
    for flag in flags {
        if flag == "-debug" {
            return true
        }
    }

    return false
}

// Creates the necessary directories for the output path.
//
// Parameters:
// - sys: The system interface used for file operations.
// - output: The output path, which may include directories that need to be created.
//
// Returns:
// - string: An error message if an error occurs while creating the directories, or an empty string on success.
@(private="file")
create_output :: proc(sys: System, output: string) -> string {
    dirs, _ := strings.split(output, "/")
    defer delete(dirs)

    curr := strings.clone(".")
    defer delete(curr)

    for dir in dirs {
        new_curr, _ := strings.concatenate({ curr, "/", dir })
        delete(curr)
        curr = new_curr

        if !sys.fs.exists(curr) {
            err := sys.fs.make_directory(curr)
            if err != nil {
                return fmt.aprintf("Error occurred while trying to create output directory %s", curr)
            }
        }
    }

    return ""
}