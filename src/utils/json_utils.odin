package utils

import "core:encoding/json"
import "core:fmt"
import "core:strings"

// Reads the `rune.json` configuration file from the root directory.
//
// This function checks if the `rune.json` file exists and can be read. If the file exists, 
// it attempts to deserialize the file's content into a `Schema` object. If there are errors 
// during reading or deserialization, it returns `false` indicating failure.
//
// Parameters:
// - sys: The system interface to handle file operations.
//
// Returns:
// - `Schema`: The deserialized schema from the `rune.json` file if the file exists and is read successfully.
// - `bool`: A boolean indicating whether the file was successfully read (`true`) or not (`false`).
read_root_file :: proc(sys: System) -> (Schema, string) {
    rune_file := "./rune.json"

    if !sys.fs.exists(rune_file) {
        return {}, strings.clone("Rune.json doesn't exists")
    }

    data, read_err := sys.fs.read_entire_file_from_path(rune_file, context.allocator)
    defer delete(data)
    if read_err != nil {
        return {}, strings.clone("Failed to read rune.json")
    }

    schema: Schema
    unmarshal_err := json.unmarshal(data, &schema)
    if unmarshal_err != nil {
        return schema, fmt.aprintf("Failed to parse schema: %s", unmarshal_err)
    }

    validation_err := validate_schema(schema)
    if validation_err != "" {
        return schema, validation_err
    }

    return schema, ""
}

// Validates the `rune.json` file.
//
// This function validates the schema to make sure the essential values are there.
//
// Parameters:
// - schema: The schema to validate.
//
// Returns:
// - A string message indicating success or the error encountered during the operation.
@(private="file")
validate_schema :: proc(schema: Schema) -> string {
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
        return strings.clone("There are duplicated profiles in your rune.json file")
    }

    if !has_target {
        return strings.clone("The selected profile does not have a target")
    }

    if !has_output {
        return strings.clone("The selected profile does not have an output")
    }

    return ""
}

// Writes the given schema to the `rune.json` file.
//
// This function creates a new `rune.json` file in the root directory. If the file already exists,
// it returns a message indicating the file already exists. The schema is serialized to JSON format,
// and if any error occurs during the serialization or writing process, an error message is returned.
//
// Parameters:
// - sys:    The system interface to handle file operations.
// - schema: The schema to serialize and write to the `rune.json` file.
//
// Returns:
// - A string message indicating success or the error encountered during the operation.
write_root_file :: proc(sys: System, schema: SchemaJson) -> string {
    path := "./rune.json"
    if sys.fs.exists(path) {
        return strings.clone("File rune.json already exists")
    }

    json_data, err := json.marshal(schema, { pretty = true, use_enum_names = true })
    defer delete(json_data)
    if err != nil {
        return fmt.aprintf("Failed to create rune.json:\n%s", err)
    }

    werr := sys.fs.write_entire_file(path, json_data)
    if werr != nil {
        return fmt.aprintf("Failed to write schema to rune.json: %s", werr)
    }

    return ""
}
