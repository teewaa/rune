#+feature dynamic-literals
package mocks

import "base:runtime"
import "core:os/os2"
import "core:encoding/json"
import "rune:utils"

mock_make_directory_no_err :: proc(name: string, perm: int = 0o755) -> os2.Error {
    return nil
}

mock_make_directory_err :: proc(name: string, perm: int = 0o755) -> os2.Error {
    return os2.General_Error.Exist
}

mock_exists_true:: proc(path: string) -> bool {
    return true
}

mock_exists_false:: proc(path: string) -> bool {
    return false
}

mock_open_ok :: proc(path: string, flags := os2.File_Flags{.Read}, perm := 0o777) -> (^os2.File, os2.Error) {
    file := new(os2.File)
    defer free(file)

    return file, nil
}

mock_open_err :: proc(path: string, flags := os2.File_Flags{.Read}, perm := 0o777) -> (^os2.File, os2.Error) {

    return nil, os2.General_Error.Exist
}

mock_close :: proc(f: ^os2.File) -> os2.Error {
    return nil
}

mock_read_dir_ok :: proc(fd: ^os2.File, n: int, allocator := context.allocator) -> ([]os2.File_Info, os2.Error) {
    return {}, nil
}

mock_read_dir_err :: proc(fd: ^os2.File, n: int, allocator := context.allocator) -> ([]os2.File_Info, os2.Error) {
    return {}, os2.General_Error.Exist
}

mock_copy_file_ok :: proc(dst_path: string, src_path: string) -> os2.Error {
    return nil
}

mock_is_dir_true :: proc(path: string) -> bool {
    return true
}

mock_is_dir_false :: proc(path: string) -> bool {
    return false
}

mock_write_entire_file_ok :: proc(path: string, data: []byte, perm: int = 0o644, truncate := true) -> os2.Error {
    return nil
}

mock_write_entire_file_err :: proc(path: string, data: []byte, perm: int = 0o644, truncate := true) -> os2.Error {
    return os2.General_Error.Exist
}

mock_get_executable_directory_WIN :: proc(allocator := context.allocator) -> string {
    return "MOCK_DIR\\MOCK_SUBDIR"
}

mock_get_executable_directory_UNIX :: proc(allocator := context.allocator) -> string {
    return "MOCK_DIR/MOCK_SUBDIR"
}

mock_read_entire_file_from_path_ok :: proc(name: string, alloc: runtime.Allocator) -> ([]byte, os2.Error) {
    schema := utils.Schema {
        default_profile = "default",
        profiles = {
            {
                name = "default",
                target = "mock_target",
                output = "mock_output"
            }
        }
    }
    defer delete(schema.scripts)

    data, _ := json.marshal(schema)

    return data, nil
}

mock_read_entire_file_from_path_duplicated_profiles :: proc(name: string, alloc: runtime.Allocator) -> ([]byte, os2.Error) {
    schema := utils.Schema {
        default_profile = "test",
        profiles = {
            {
                name = "test",
                target = "mock_target",
                output = "mock_output"
            },
            {
                name = "test",
                target = "mock_target",
                output = "mock_output"
            }
        }
    }

    defer delete(schema.scripts)

    data, _ := json.marshal(schema)

    return data, nil
}

mock_read_entire_file_from_path_no_output :: proc(name: string, alloc: runtime.Allocator) -> ([]byte, os2.Error) {
    schema := utils.Schema {
        default_profile = "default",
        profiles = {
            {
                name = "default",
                output = "",
                target = "mock_target",
            }
        }
    }

    data, _ := json.marshal(schema)

    return data, nil
}

mock_read_entire_file_from_path_no_target :: proc(name: string, alloc: runtime.Allocator) -> ([]byte, os2.Error) {
    schema := utils.Schema {
        default_profile = "default",
        profiles = {
            {
                name = "default",
                target = "",
                output = "."
            }
        }
    }

    defer delete(schema.scripts)

    data, _ := json.marshal(schema)

    return data, nil
}

mock_read_entire_file_from_path_no_build_mode :: proc(name: string, alloc: runtime.Allocator) -> ([]byte, os2.Error) {
    schema := utils.Schema {
        default_profile = "default",
        profiles = {
            {
                name = "default",
                target = "mock_target",
                output = "",
            }
        }
    }

    defer delete(schema.scripts)

    data, _ := json.marshal(schema)

    return data, nil
}

mock_read_entire_file_from_path_err :: proc(name: string, alloc: runtime.Allocator) -> ([]byte, os2.Error) {
    return {}, os2.General_Error.Exist
}

mock_file_close_ok :: proc(file: ^os2.File) -> os2.Error {
    return nil
}

mock_file_close_err :: proc(file: ^os2.File) -> os2.Error {
    return os2.General_Error.Exist
}