#+feature dynamic-literals
package cmds_tests

import "core:testing"
import "tests:mocks"
import "rune:cmds"
import "rune:utils"

@(test)
should_process_valid_script :: proc(t: ^testing.T) {
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

    schema := utils.Schema {
        scripts = {
            "test" = "test"
        }
    }

    defer delete(schema.scripts)

    success, res := cmds.process_script(sys, {"test"}, schema)
    defer delete(res)
    defer delete(success)
    testing.expect_value(t, res, "")
    testing.expect_value(t, success, "Successfully executed script")
}

@(test)
should_not_process_valid_script :: proc(t: ^testing.T) {
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

    schema := utils.Schema {
        scripts = {
            "test" = "test"
        }
    }

    defer delete(schema.scripts)

    _, res := cmds.process_script(sys, {"invalid"}, schema)
    defer delete(res)
    testing.expect_value(t, res, "Script invalid doesn't exists")
}

@(test)
should_handle_script_err :: proc(t: ^testing.T) {
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

    schema := utils.Schema {
        scripts = {
            "test" = "test"
        }
    }

    defer delete(schema.scripts)

    _, res := cmds.process_script(sys, {"test"}, schema)
    defer delete(res)
    testing.expect_value(t, res, "Script test failed with Exist")
}