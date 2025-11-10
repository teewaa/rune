package mocks

import "core:os/os2"

mock_pipe_ok :: proc() -> (r, w: ^os2.File, err: os2.Error) {
    return {}, {}, nil
}

mock_pipe_err :: proc() -> (r, w: ^os2.File, err: os2.Error) {
    return {}, {}, os2.General_Error.Exist
}

mock_process_start_ok :: proc(desc: os2.Process_Desc) -> (os2.Process, os2.Error) {
    return {}, nil
}

mock_process_start_err :: proc(desc: os2.Process_Desc) -> (os2.Process, os2.Error) {
    return {}, os2.General_Error.Exist
}

mock_process_wait_ok :: proc(process: os2.Process, timeout := os2.TIMEOUT_INFINITE) -> (os2.Process_State, os2.Error) {
    return {}, nil
}

mock_process_wait_err :: proc(process: os2.Process, timeout := os2.TIMEOUT_INFINITE) -> (os2.Process_State, os2.Error) {
    return {}, os2.General_Error.Exist
}

mock_process_close_ok :: proc(process: os2.Process) -> os2.Error {
    return nil
}

mock_process_close_err :: proc(process: os2.Process) -> os2.Error {
    return os2.General_Error.Exist
}