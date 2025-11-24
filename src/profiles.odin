package main

import os "core:os/os2"
import "core:fmt"
import "core:strings"


get_profile :: proc(schema: Schema, name: string) -> (SchemaProfile, Error) {
    if name == "" {
        fmt.eprintln("No default profile was set. Make sure to define one or specify one by running \"rune [command] [profile]\"")
        return {}, .UNDEFINED_PROFILE
    }

    for p in schema.profiles {
        if p.name == name {
            return p, nil
        }
    }

    fmt.eprintfln("Failed to find \"%s\" in the list of profiles", name)
    return {}, .UNDEFINED_PROFILE
}

process_profile:: proc(profile: SchemaProfile, schema: Schema, cmd: string, is_verbose: bool) -> Error {
    output := parse_output(profile, cmd)
    defer delete(output)

    output_err := create_output(output)
    if output_err != nil {
        return output_err
    }
    
    ext, ext_err := get_extension(profile.arch, profile.build_mode)
    if ext_err != nil { return ext_err }

    output_w_target, _ := strings.concatenate({output, profile.target, ext})
    defer delete(output_w_target)

    err := process_odin_cmd(profile, schema.scripts, output_w_target, cmd, is_verbose)
    if err != nil { return err }

    return nil
}

@(private="file")
parse_output :: proc(profile: SchemaProfile, cmd: string) -> string {
    is_debug := check_debug(profile.flags)

    output := profile.output
    allocated := false
    
    if strings.contains(output, "{config}") {
        tmp, _ := strings.replace(output, "{config}", is_debug ? "debug" : "release", -1)
        if allocated do delete(output)
        output = tmp
        allocated = true
    }
    if strings.contains(output, "{arch}") {
        tmp, _ := strings.replace(output, "{arch}", profile.arch, -1)
        if allocated do delete(output)
        output = tmp
        allocated = true
    }
    if strings.contains(output, "{profile}") {
        tmp, _ := strings.replace(output, "{profile}", profile.name, -1)
        if allocated do delete(output)
        output = tmp
        allocated = true
    }
    
    if len(output) > 1 && output[len(output)-1] != '/' {
        tmp := strings.concatenate({output, "/"})
        if allocated do delete(output)
        output = tmp
        allocated = true
    }

    return output
}

@(private="file")
check_debug :: proc(flags: [dynamic]string) -> bool {
    for flag in flags {
        if flag == "-debug" {
            return true
        }
    }

    return false
}

@(private="file")
create_output :: proc(output: string) -> Error {
    dirs, _ := strings.split(output, "/")
    defer delete(dirs)

    curr := strings.clone(".")
    defer delete(curr)

    for dir in dirs {
        new_curr, _ := strings.concatenate({ curr, "/", dir })
        delete(curr)
        curr = new_curr

        if !os.exists(curr) {
            err := os.make_directory(curr)
            if err != nil {
                fmt.eprintfln("Error occurred while trying to create output directory %s", curr)
                return err
            }
        }
    }

    return nil
}