package utils

import "core:fmt"
import "core:strings"
import "core:os/os2"
import "core:thread"
import "rune:logger"

T_Data :: struct {
    out_r: ^os2.File,
    err_r: ^os2.File,
    process_done: ^bool
}

// Executes a script command and returns its standard output and error.
//
// Parameters:
// - sys (System): The system context that manages the process execution.
// - script (string): The script or command to execute.
//
// Returns:
// - A string containing the standard output from the script.
// - A string containing the standard error from the script.
execute_script_with_logs :: proc(sys: System, script: string) -> string {
    cmds: []string
    if ODIN_OS == .Linux {
        cmds = { "bash", "-i", "-c", script }
    } else {
        cmds = strings.split(script, " ")
    }

    stdout_r, stdout_w, _ := sys.process.pipe()
    stderr_r, stderr_w, _ := sys.process.pipe()

    defer sys.fs.close(stderr_r)
    defer sys.fs.close(stdout_r)

    t: ^thread.Thread
    done := false
    data := T_Data {
        out_r = stdout_r,
        err_r = stderr_r,
        process_done = &done
    }

    p, _ := sys.process.process_start({
        command = cmds,
        stdout = stdout_w,
        stderr = stderr_w,
    })

    if ODIN_OS != .Linux {
        delete(cmds)
    }

    t = thread.create_and_start_with_poly_data(&data, get_logs_from_process)
    defer thread.destroy(t)

    state, process_err := sys.process.process_wait(p)
    _ = sys.process.process_close(p)
    done = true

    if process_err != nil {
        return fmt.aprintf("Script %s failed with %s", script, process_err)
    }

    sys.fs.close(stdout_w)
    sys.fs.close(stderr_w)

    if state.exit_code != 0 {
        os2.exit(state.exit_code)
    }

    return ""
}

// Handler in a separate thread that listens to the stdout and stderr
// from another process.
//
// Parameters:
// - data: Pointer to the data used by the thread
get_logs_from_process :: proc(data: ^T_Data) {
    buf: [1024]u8 = ---
    err: os2.Error
    stdout_done, stderr_done, has_data: bool
    
    for (!stdout_done || !stderr_done) && !data.process_done^ {
        n := 0

        if !stdout_done {
            has_data, err = os2.pipe_has_data(data.out_r)
            if has_data {
                n, err = os2.read(data.out_r, buf[:])
            }

            switch err {
            case nil:
                if n > 0 {
                    logger.infosl(string(buf[0:n]))
                }
            case .EOF, .Broken_Pipe:
                stdout_done = true
                err = nil
            }
        }

        if err == nil && !stderr_done {
            n = 0
            has_data, err = os2.pipe_has_data(data.err_r)
            if has_data {
                n, err = os2.read(data.err_r, buf[:])
            }

            switch err {
            case nil:
                if n > 0 {
                    logger.infosl(string(buf[0:n]))
                }
            case .EOF, .Broken_Pipe:
                stderr_done = true
                err = nil
            }
        }
    }
}

// Copies a file or directory from the source location to the destination.
//
// Parameters:
// - sys: The system context that manages file and directory operations.
// - original_from: The original root path of the source.
// - from: The source path (file or directory) to copy.
// - to: The destination path where the file or directory should be copied to.
//
// Returns:
// - A string describing any error that occurred during the copy operation, or an empty string if the operation was successful.
process_copy :: proc(sys: System, original_from: string, from: string, to: string) -> string {
    if sys.fs.is_dir(from) {
        extra := strings.trim_prefix(from, original_from)
        new_dir, _ := strings.concatenate({to, extra})
        defer delete(new_dir)

        if !sys.fs.exists(new_dir) {
            err := sys.fs.make_directory(new_dir)
            if err != nil {
                return fmt.aprintf("Failed to create directory %s: %s", new_dir, err)
            }
        }

        dir, err := sys.fs.open(from)
        if err != nil {
            return fmt.aprintf("Failed to open directory %s: %s", from, err)
        }
        defer sys.fs.close(dir)

        files: []os2.File_Info
        files, err = sys.fs.read_dir(dir, -1, context.allocator)
        defer delete(files)
        if err != nil {
            return fmt.aprintf("Failed to read files from %s: %s", from, err)
        }

        for file in files {
            name, _ := strings.replace(file.fullpath, "\\", "/", -1)
            defer delete(name)
            copy_err := process_copy(sys, original_from, name, to)
            if copy_err != "" {
                return copy_err
            }
        }

        return ""
    }

    extra := strings.trim_prefix(from, original_from)
    real_to := strings.concatenate({to, extra})
    defer delete(real_to)
    
    copy_err := sys.fs.copy_file(real_to, from)
    if copy_err != nil{
        return fmt.aprintf("Failed to copy: %s", copy_err)
    }

    return ""
}