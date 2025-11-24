package main

import "core:encoding/json"
import "core:fmt"
import os "core:os/os2"

RUNE_FILE   :: "./rune.json"

get_rune_schema :: proc() -> (Schema, Error) {
    if !os.exists(RUNE_FILE) {
        return {}, .ROOT_FILE_MISSING
    }

    data, read_err := os.read_entire_file_from_path(RUNE_FILE, context.allocator)
    defer delete(data)
    if read_err != nil {
        fmt.eprintln("Failed to read rune.json")
        return {}, read_err
    }

    schema: Schema
    unmarshal_err := json.unmarshal(data, &schema)
    if unmarshal_err != nil {
        fmt.eprintln("Failed to parse rune schema")
        return {}, unmarshal_err
    }

    is_valid := validate_schema(&schema)
    if !is_valid {
        destroy_schema(schema)
        return {}, .INVALID_SCHEMA
    }

    return schema, nil
}

destroy_schema :: proc(schema: Schema) {
    for p in schema.profiles {
        delete(p.arch)
        delete(p.build_mode)
        delete(p.entry)
        for f in p.flags {
            delete(f)
        }
        delete(p.flags)
        delete(p.name)
        delete(p.output)
        delete(p.target)
        for c in p.post_build.copy {
            delete(c.to)
            delete(c.from)
        }
        delete(p.post_build.copy)
        for s in p.post_build.scripts {
            delete(s)
        }
        delete(p.post_build.scripts)
        for c in p.pre_build.copy {
            delete(c.to)
            delete(c.from)
        }
        delete(p.pre_build.copy)
        for s in p.pre_build.scripts {
            delete(s)
        }
        delete(p.pre_build.scripts)
    }

    delete(schema.profiles)
    delete(schema.default_profile)
    delete(schema.default_test_profile)
    delete(schema.version)
    for s, v in schema.scripts {
        delete(s)
        delete(v)
    }
    delete(schema.scripts)
}

@(private="file")
validate_schema :: proc(schema: ^Schema) -> bool {
    seen_profiles := map[string]bool{}
    defer delete(seen_profiles)
    has_duplicated_profiles := false
    has_target := true
    has_output := true
    for profile in schema.profiles {
        if seen_profiles[profile.name] {
            has_duplicated_profiles = true
            break
        }
        seen_profiles[profile.name] = true
        
        if profile.target == "" {
            has_target = false
            break
        }

        if profile.output == "" {
            has_output = false
            break
        }
    }

    if has_duplicated_profiles {
        fmt.eprintfln("There are duplicated profiles in your rune.json file")
        return false
    }

    if !has_target {
        fmt.eprintln("The selected profile does not have a target")
        return false
    }

    if !has_output {
        fmt.eprintln("The selected profile does not have an output")
        return true
    }

    return true
}

write_root_file :: proc(schema: SchemaJson) -> Error {
    if os.exists(RUNE_FILE) {
        fmt.eprintln("File rune.json already exists")
        return .RUNE_FILE_EXISTS
    }

    json_data, err := json.marshal(schema, { pretty = true, use_enum_names = true })
    defer delete(json_data)
    if err != nil {
        fmt.eprintfln("Failed to create rune.json, error in parsing schema")
        return err
    }

    w_err := os.write_entire_file(RUNE_FILE, json_data)
    if w_err != nil {
        fmt.eprintfln("Failed to write schema to rune.json")
        return w_err
    }

    return nil
}