package utils_tests

import "core:testing"
import "tests:mocks"
import "rune:utils"

@(test)
process_valid_script :: proc(t: ^testing.T) {
    sys := utils.System {
        fs = {
            close = mocks.mock_file_close_ok,
        },
        process = {
            pipe = mocks.mock_pipe_ok,
            process_start = mocks.mock_process_start_ok,
            process_wait = mocks.mock_process_wait_ok,
            process_close = mocks.mock_process_close_ok,
        },
    }

    res := utils.execute_script_with_logs(sys, "")
    defer delete(res)
    testing.expect_value(t, res, "")
}

@(test)
process_err_script :: proc(t: ^testing.T) {
    sys := utils.System {
        fs = {
            close = mocks.mock_file_close_ok,
        },
        process = {
            pipe = mocks.mock_pipe_ok,
            process_start = mocks.mock_process_start_ok,
            process_wait = mocks.mock_process_wait_err,
            process_close = mocks.mock_process_close_ok,
        },
    }

    res := utils.execute_script_with_logs(sys, "test")
    defer delete(res)
    testing.expect_value(t, res, "Script test failed with Exist")
}

@(test)
should_process_copy :: proc(t: ^testing.T) {
    sys := utils.System {
        fs = {
            is_dir = mocks.mock_is_dir_false,
            copy_file = mocks.mock_copy_file_ok
        }
    }

    res := utils.process_copy(sys, ".", ".", ".")
    defer delete(res)
    testing.expect_value(t, res, "")
}

@(test)
should_fail_copy_if_mkdir_err :: proc(t: ^testing.T) {
    sys := utils.System {
        fs = {
            is_dir = mocks.mock_is_dir_true,
            exists = mocks.mock_exists_false,
            make_directory = mocks.mock_make_directory_err
        }
    }

    res := utils.process_copy(sys, ".", ".", "test")
    defer delete(res)
    testing.expect_value(t, res, "Failed to create directory test: Exist")
}

@(test)
should_fail_copy_if_open_err :: proc(t: ^testing.T) {
    sys := utils.System {
        fs = {
            is_dir = mocks.mock_is_dir_true,
            exists = mocks.mock_exists_true,
            open = mocks.mock_open_err
        }
    }

    res := utils.process_copy(sys, ".", ".", "test")
    defer delete(res)
    testing.expect_value(t, res, "Failed to open directory .: Exist")
}

@(test)
should_fail_copy_if_read_dir_fails :: proc(t: ^testing.T) {
    sys := utils.System {
        fs = {
            is_dir = mocks.mock_is_dir_true,
            exists = mocks.mock_exists_true,
            open = mocks.mock_open_ok,
            close = mocks.mock_close,
            read_dir = mocks.mock_read_dir_err
        }
    }

    res := utils.process_copy(sys, ".", ".", "test")
    defer delete(res)
    testing.expect_value(t, res, "Failed to read files from .: Exist")
}

@(test)
should_fail_copy_files_with_directory :: proc(t: ^testing.T) {
    sys := utils.System {
        fs = {
            is_dir = mocks.mock_is_dir_true,
            exists = mocks.mock_exists_true,
            open = mocks.mock_open_ok,
            close = mocks.mock_close,
            read_dir = mocks.mock_read_dir_ok
        }
    }

    res := utils.process_copy(sys, ".", ".", "test")
    defer delete(res)
    testing.expect_value(t, res, "")
}