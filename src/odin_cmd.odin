package main

/*
    List of predefined variables

    config:     Build mode
    arch:       Targeted architecture
    profile:    Name of the profile
*/

import "core:fmt"
import filepath "core:path/filepath"
import "core:strings"

@(private="file")
BuildData :: struct {
    entry:      string,
    output:     string,
    flags:      [dynamic]string,
    arch:       string,
    mode:       string,
    version:    string
}

process_odin_cmd :: proc(
    profile: SchemaProfile,
    scripts: map[string]string,
    output: string,
    cmd: string,
    is_verbose: bool
) -> Error {
    if len(profile.pre_build.copy) > 0 || len(profile.pre_build.scripts) > 0 {
        pre_build_err := execute_build_sequence(profile.pre_build, scripts, output)
        if pre_build_err != nil { return pre_build_err }
    }

    cmd_err := execute_cmd(BuildData{
        entry = profile.entry,
        output = output,
        flags = profile.flags,
        arch = profile.arch,
        mode = profile.build_mode
    }, cmd, is_verbose)
    
    if cmd_err != nil { return cmd_err }

    if len(profile.post_build.copy) > 0 || len(profile.post_build.scripts) > 0 {
        post_build_err := execute_build_sequence(profile.post_build, scripts, output)
        if post_build_err != nil { return post_build_err }
    }

    return nil
}

@(private="file")
execute_cmd :: proc(data: BuildData, build_cmd: string, is_verbose: bool) -> Error {
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

    if data.version != "" {
        out := fmt.aprintf("-DVERSION:%s", data.version)
        new_cmd, _ := strings.join({cmd, out}, " ")
        delete(out)
        delete(cmd)
        cmd = new_cmd
    }

    if is_verbose {
        fmt.println(cmd)
        fmt.println()
    }

    script_err := execute_script_with_logs(cmd)
    if script_err != nil { return script_err }
    
    return nil
}

@(private="file")
execute_build_sequence :: proc(steps: SchemaBuildStep, script_list: map[string]string, output: string) -> Error {
    for copy in steps.copy {
        output_dir := filepath.dir(output)
        defer delete(output_dir)
        output_copy_dir := filepath.join({output_dir, copy.to})
        defer delete(output_copy_dir)
        
        copy_err := process_copy(copy.from, copy.from, output_copy_dir)
        if copy_err != nil { return copy_err }
        
    }

    script_err := execute_scripts(steps.scripts, script_list)
    if script_err != nil { return script_err }

    return nil
}

@(private="file")
execute_scripts :: proc(step_scripts: []string, script_list: map[string]string) -> Error {
    for script_name in step_scripts {
        script := script_list[script_name] or_else ""
        if script == "" {
            fmt.eprintfln("Script %s is not defined in rune.json", script_name)
            return .UNDEFINED_SCRIPT
        }

        script_err := execute_script_with_logs(script)
        if script_err != nil {
            return script_err
        }
    }

    return nil
}