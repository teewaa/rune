package main

import "base:runtime"
import "core:os/os2"

System :: struct {
    fs:         FileSystem,
    process:    Process,
    verbose:    bool,
}

FileSystem :: struct {
    exists:                     proc(path: string) -> bool,
    make_directory:             proc(name: string, perm: int = 0o755) -> os2.Error,
    copy_file:                  proc(dst_path: string, src_path: string) -> os2.Error,
    read_dir:                   proc(fd: ^os2.File, n: int, allocator := context.allocator) -> ([]os2.File_Info, os2.Error),
    open:                       proc(name: string, flags := os2.File_Flags{.Read}, perm := 0o777) -> (^os2.File, os2.Error),
    close:                      proc(f: ^os2.File) -> os2.Error,
    is_dir:                     proc(path: string) -> bool,
    read_entire_file_from_path: proc(name: string, allocator: runtime.Allocator) -> ([]byte, os2.Error),
    write_entire_file:          proc(name: string, data: []byte, perm: int = 0o644, truncate := true) -> os2.Error,
    get_current_directory:      proc(allocator := context.allocator) -> string,
}

Process :: struct {
    pipe:           proc() -> (r, w: ^os2.File, err: os2.Error),
    process_start:  proc(desc: os2.Process_Desc) -> (os2.Process, os2.Error),
    process_wait:   proc(process: os2.Process, timeout := os2.TIMEOUT_INFINITE) -> (os2.Process_State, os2.Error),
    process_close:  proc(process: os2.Process) -> os2.Error,
}