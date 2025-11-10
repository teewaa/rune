package utils

/*
    List of predefined variables

    config:     Build mode
    arch:       Targeted architecture
    profile:    Name of the profile
*/

import "core:fmt"
import filepath "core:path/filepath"
import "core:strings"
import "rune:logger"

// BuildData defines the structure for holding build-related information like entry, output, flags, and architecture.
BuildData :: struct {
    entry:  string,             // Path to the entry point (e.g., source file)
    output: string,             // Output file location
    flags:  [dynamic]string,    // Additional flags for the Odin command
    arch:   string ,            // Target architecture for the build
    mode:   string              // Build mode for the target project
}

// Processes and executes the Odin build command for a given profile.
//
// This function handles pre-build, build, and post-build steps for the provided profile.
// It first executes any pre-build scripts, runs the Odin build command, and then processes
// any post-build operations such as copying files or running additional scripts.
//
// Parameters:
// - sys:       The system interface to handle file operations.
// - profile:   The build profile containing configurations such as entry point, flags, and architecture.
// - scripts:   A map of predefined scripts that can be executed during the build process.
// - output:    The output path for the build.
// - cmd:       The Odin build command to execute.
//
// Returns:
// - A string containing any error message, or an empty string if successful.
process_odin_cmd :: proc(
    sys: System,
    profile: SchemaProfile,
    scripts: map[string]string,
    output: string,
    cmd: string
) -> (string) {
    if len(profile.pre_build.copy) > 0 || len(profile.pre_build.scripts) > 0 {
        pre_build_err := execute_build_sequence(sys, profile.pre_build, scripts, output)

        if pre_build_err != "" {
            return pre_build_err
        }
    }

    cmd_err := execute_cmd(sys, BuildData{
        entry = profile.entry,
        output = output,
        flags = profile.flags,
        arch = profile.arch,
        mode = profile.build_mode
    }, cmd)
    
    if cmd_err != "" {
        return cmd_err
    }

    if len(profile.post_build.copy) > 0 || len(profile.post_build.scripts) > 0 {
        post_build_err := execute_build_sequence(sys, profile.post_build, scripts, output)

        if post_build_err != "" {
            return post_build_err
        }
    }

    return ""
}

// Executes the Odin build command with the provided build data.
//
// This function constructs the final command by appending flags and other options based on the
// provided build data (entry point, output path, architecture, and additional flags). It then
// runs the command and handles any output or error.
//
// Parameters:
// - sys:    The system interface to handle file operations.
// - data:   The build data containing entry point, output path, flags, and architecture.
// - buildCmd: The base Odin command to execute (e.g., "build").
//
// Returns:
// - A string containing any error message, or an empty string if successful.
@(private="file")
execute_cmd :: proc(sys: System, data: BuildData, build_cmd: string) -> string {
    cmd, _ := strings.join({"odin", build_cmd}, " ")
    defer delete(cmd)

    if data.entry != "" {
        new_cmd, _ := strings.join({cmd, data.entry}, " ")
        delete(cmd)
        cmd = new_cmd
    }

    if data.output != "" {
        out := fmt.aprintf("-out:%s", data.output)
        new_cmd, _ := strings.join({cmd, out}, " ")
        delete(out)
        delete(cmd) 
        cmd = new_cmd
    }

    if data.mode != "" && build_cmd != "run" {
        mode := fmt.aprintf("-build-mode:%s", data.mode)
        new_cmd, _ := strings.join({cmd, mode}, " ")
        delete(mode)
        delete(cmd)
        cmd = new_cmd
    }

    if data.arch != "" {
        out := fmt.aprintf("-target:%s", data.arch)
        new_cmd, _ := strings.join({cmd, out}, " ")
        delete(out)
        delete(cmd)
        cmd = new_cmd
    }
    
    if len(data.flags) > 0 {
        for flag in data.flags {
            new_cmd, _ := strings.join({cmd, flag}, " ")
            delete(cmd)
            cmd = new_cmd
        }
    }

    if sys.verbose {
        logger.info(cmd)
        logger.info()
    }

    script_err := execute_script_with_logs(sys, cmd)

    if script_err != "" {
        return script_err
    }
    
    return ""
}

// Executes the post-build actions defined in the profile, such as file copying or running scripts.
//
// This function processes both file copy operations and post-build scripts.
//
// Parameters:
// - sys:         The system interface to handle file operations.
// - post_build:  The post-build configuration (e.g., file copy actions and scripts).
// - script_list: A map of predefined scripts that can be executed.
// - output:      Output for the process_copy command
//
// Returns:
// - A string containing any error message, or an empty string if successful.
@(private="file")
execute_build_sequence :: proc(sys: System, steps: SchemaBuildStep, script_list: map[string]string, output: string) -> string {
    for copy in steps.copy {
        output_dir := filepath.dir(output)
        defer delete(output_dir)
        output_copy_dir := filepath.join({output_dir, copy.to})
        defer delete(output_copy_dir)
        copy_err := process_copy(sys, copy.from, copy.from, output_copy_dir)
        if copy_err != "" {
            return copy_err
        }
    }

    script_err := execute_scripts(sys, steps.scripts, script_list)
    if script_err != "" {
        return script_err
    }

    return ""
}

// Executes a series of scripts.
//
// This function iterates over the provided scripts and executes each one in the specified order.
//
// Parameters:
// - sys:         The system interface to handle file operations.
// - step_scripts: A list of scripts to be executed.
// - script_list: A map of predefined scripts that can be executed.
//
// Returns:
// - A string containing any error message, or an empty string if successful.
@(private="file")
execute_scripts :: proc(sys: System, step_scripts: []string, script_list: map[string]string) -> string {
    for script_name in step_scripts {
        script := script_list[script_name] or_else ""
        if script == "" {
            return fmt.aprintf("Script %s is not defined in rune.json", script_name)
        }

        script_err := execute_script_with_logs(sys, script)
        
        if script_err != "" {
            return script_err
        }
    }

    return ""
}
