package main

import "base:runtime"
import "core:encoding/json"
import os "core:os/os2"

Rune_Error :: enum {
    ROOT_FILE_MISSING,
    INVALID_SCHEMA,
    NO_DEFAULT_PROFILE,
    UNDEFINED_SCRIPT,
    UNDEFINED_PROFILE,
    INVALID_EXTENSION,
    INVALID_PLATFORM,
    SCRIPT_ERROR,
    INVALID_BUILD_MODE,
    NO_BUILD_MODE_SPECIFIED,
    RUNE_FILE_EXISTS,
    INVALID_FILE_FLAG_VALUE,
    INVALID_PACKAGE_FLAG_VALUE,
    INVALID_TEST_FLAG_VALUE,
    INVALID_SCRIPT,
    SCRIPT_NOT_FOUND,
    INVALID_RUNE_PROFILE,
    INVALID_OUTPUT_VALUE
}

Error :: union {
    os.Error,
    runtime.Allocator_Error,
    json.Unmarshal_Error,
    json.Marshal_Error,
    Rune_Error
}