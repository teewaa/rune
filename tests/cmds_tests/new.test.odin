package cmds_tests

import "core:testing"
import "tests:mocks"
import "rune:cmds"
import "rune:utils"


@(test)
should_create_rune_json_file :: proc(t: ^testing.T) {
    sys := utils.System {
        fs = {
            exists = mocks.mock_exists_false,
            write_entire_file = mocks.mock_write_entire_file_ok
        }
    }

    success, res := cmds.process_new(sys, { "new", "exe", "-o:test" })
    defer delete(success)
    testing.expect_value(t, res, "")
    testing.expect_value(t, success, "Done")
}

@(test)
should_fail_if_invalid_output_flag :: proc(t: ^testing.T) {
    sys := utils.System {
        fs = {
            exists = mocks.mock_exists_false
        }
    }

    _, res := cmds.process_new(sys, { "new", "exe", "-o" })
    defer delete(res)
    testing.expect_value(t, res, "Invalid output flag -o. Make sure it is formatted -o:<target_name>")
}

@(test)
should_succeed_without_output_flag :: proc(t: ^testing.T) {
    sys := utils.System {
        fs = {
            exists = mocks.mock_exists_false,
            write_entire_file = mocks.mock_write_entire_file_ok,
            get_current_directory = mocks.mock_get_executable_directory_WIN
        }
    }

    sucess, res := cmds.process_new(sys, { "new", "exe" })
    defer delete(res)
    defer delete(sucess)
    testing.expect_value(t, res, "")
    testing.expect_value(t, sucess, "Done")
}

@(test)
should_fail_if_invalid_build_mode :: proc(t: ^testing.T) {
    sys := utils.System {}

    _, res := cmds.process_new(sys, { "new", "invalid" })
    defer delete(res)
    testing.expect_value(t, res, "invalid is not supported as a build mode")
}

@(test)
should_fail_if_file_already_exists :: proc(t: ^testing.T) {
    sys := utils.System {
        fs = {
            exists = mocks.mock_exists_true,
            get_current_directory = mocks.mock_get_executable_directory_WIN
        }
    }

    _, res := cmds.process_new(sys, { "new", "exe", "-o:test" })
    defer delete(res)
    testing.expect_value(t, res, "File rune.json already exists")
}

@(test)
should_fail_if_write_entire_file_fails :: proc(t: ^testing.T) {
    sys := utils.System {
        fs = {
            exists = mocks.mock_exists_false,
            write_entire_file = mocks.mock_write_entire_file_err,
            get_current_directory = mocks.mock_get_executable_directory_WIN
        }
    }

    _, res := cmds.process_new(sys, { "new", "exe", "-o:test" })
    defer delete(res)
    testing.expect_value(t, res, "Failed to write schema to rune.json: Exist")
}