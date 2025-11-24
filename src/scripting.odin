package main

import "core:fmt"
import "core:strings"
import os "core:os/os2"
import "core:thread"

T_Data :: struct {
    out_r: ^os.File,
    err_r: ^os.File,
    process_done: ^bool
}

execute_script_with_logs :: proc(script: string) -> Error {
    cmds: []string
    if ODIN_OS == .Linux {
        cmds = { "bash", "-i", "-c", script }
    } else {
        cmds = strings.split(script, " ")
    }

    stdout_r, stdout_w, _ := os.pipe()
    stderr_r, stderr_w, _ := os.pipe()

    defer os.close(stderr_r)
    defer os.close(stdout_r)

    t: ^thread.Thread
    done := false
    data := T_Data {
        out_r = stdout_r,
        err_r = stderr_r,
        process_done = &done
    }

    p, _ := os.process_start({
        command = cmds,
        stdout = stdout_w,
        stderr = stderr_w,
    })

    if ODIN_OS != .Linux {
        delete(cmds)
    }

    t = thread.create_and_start_with_poly_data(&data, get_logs_from_process)
    defer thread.destroy(t)

    state, process_err := os.process_wait(p)
    _ = os.process_close(p)
    done = true

    if process_err != nil {
        fmt.eprintfln("Script %s failed with %s", script, process_err)
        return .SCRIPT_ERROR
    }

    os.close(stdout_w)
    os.close(stderr_w)

    if state.exit_code != 0 {
        fmt.eprintfln("Script exited with code: %d", state.exit_code)
        return .SCRIPT_ERROR
    }

    return nil
}

// Handler in a separate thread that listens to the stdout and stderr
// from another process.
//
// Parameters:
// - data: Pointer to the data used by the thread
get_logs_from_process :: proc(data: ^T_Data) {
    buf: [1024]u8 = ---
    err: os.Error
    stdout_done, stderr_done, has_data: bool
    
    for (!stdout_done || !stderr_done) && !data.process_done^ {
        n := 0

        if !stdout_done {
            has_data, err = os.pipe_has_data(data.out_r)
            if has_data {
                n, err = os.read(data.out_r, buf[:])
            }

            switch err {
            case nil:
                if n > 0 {
                    fmt.print(string(buf[0:n]))
                }
            case .EOF, .Broken_Pipe:
                stdout_done = true
                err = nil
            }
        }

        if err == nil && !stderr_done {
            n = 0
            has_data, err = os.pipe_has_data(data.err_r)
            if has_data {
                n, err = os.read(data.err_r, buf[:])
            }

            switch err {
            case nil:
                if n > 0 {
                    fmt.eprint(string(buf[0:n]))
                }
            case .EOF, .Broken_Pipe:
                stderr_done = true
                err = nil
            }
        }
    }
}

process_copy :: proc(original_from: string, from: string, to: string) -> Error {
    if os.is_dir(from) {
        extra := strings.trim_prefix(from, original_from)
        new_dir, _ := strings.concatenate({to, extra})
        defer delete(new_dir)

        if !os.exists(new_dir) {
            err := os.make_directory(new_dir)
            if err != nil {
                fmt.eprintf("Failed to create directory %s: %s", new_dir, err)
                return err
            }
        }

        dir, err := os.open(from)
        if err != nil {
            fmt.eprintfln("Failed to open directory %s: %s", from, err)
            return err
        }

        defer os.close(dir)

        files: []os.File_Info
        files, err = os.read_dir(dir, -1, context.allocator)
        if err != nil {
            fmt.eprintfln("Failed to read files from %s: %s", from, err)
            return err
        }
        defer delete(files)

        for file in files {
            defer os.file_info_delete(file, context.allocator)
            name, _ := strings.replace(file.fullpath, "\\", "/", -1)
            defer delete(name)

            copy_err := process_copy(original_from, name, to)
            if copy_err != nil { return copy_err }
        }

        return nil
    }

    extra := strings.trim_prefix(from, original_from)
    real_to := strings.concatenate({to, extra})
    defer delete(real_to)
    
    copy_err := os.copy_file(real_to, from)
    if copy_err != nil {
        fmt.eprintfln("Failed to copy: %s", copy_err)
        return copy_err
    }

    return nil
}