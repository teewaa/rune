package utils

import "core:fmt"
import "rune:logger"

// Enum containing the different platforms
Platform :: enum {
    Windows,
    Unix,
    Mac,
    Unknown
}

project_types := []string {
    "exe",
    "test",
    "dll",
    "shared",
    "dynamic",
    "lib",
    "static",
    "obj",
    "object",
    "asm",
    "assembly",
    "assembler",
    "llvm",
    "llvm-ir" 
}

// Given a target architecture, returns the appropriate platform.
//
// Parameters:
// - arch: The target architecture (e.g., "windows_amd64", "linux_amd64").
//
// Returns:
// - Platform: The platform corresponding to the architecture (Windows, Unix, Mac, Unknown).
// - bool: A flag indicating whether the architecture is supported or not.
get_platform :: proc(arch: string) -> (Platform, bool) {
    switch arch {
        case "windows_i386", "windows_amd64":
            return .Windows, true
        case "linux_i386", "linux_amd64", "linux_arm64", "linux_arm32", "linux_riscv64",
            "freebsd_i386", "freebsd_amd64", "freebsd_arm64", 
            "netbsd_amd64", "netbsd_arm64", 
            "openbsd_amd64", "haiku_amd64", 
            "freestanding_wasm32", "wasi_wasm32", "js_wasm32", "orca_wasm32",
            "freestanding_wasm64p32", "js_wasm64p32", "wasi_wasm64p32", 
            "freestanding_amd64_sysv", "freestanding_amd64_win64", 
            "freestanding_arm64", "freestanding_arm32", "freestanding_riscv64":
           return .Unix, true
        case "darwin_amd64", "darwin_arm64":
            return .Mac, true
    }

    return .Unknown, false
}

// Returns the appropriate file extension for Windows based on the build mode.
//
// Parameters:
// - mode (string): The build mode (e.g., "exe", "dll", "static", etc.).
//
// Returns:
// - string: The file extension for the given build mode on Windows.
// - bool: A flag indicating whether the build mode is supported on Windows.
@(private="file")
get_windows_ext :: proc(mode: string) -> (string, bool) {
    switch mode {
        case "", "exe", "test":
            return ".exe", true
        case "dll", "shared", "dynamic":
            return ".dll", true
        case "lib", "static":
            return ".lib", true
        case "obj", "object":
            return ".obj", true
        case "assembly", "assembler", "asm":
            return ".asm", true
        case "llvm-lr", "llvm":
            return ".ll", true
    }

    return "", false
}

// Returns the appropriate file extension for Unix-based platforms (Linux, FreeBSD, etc.) based on the build mode.
//
// Parameters:
// - mode: The build mode (e.g., "exe", "dll", "static", etc.).
//
// Returns:
// - string: The file extension for the given build mode on Unix-based platforms.
// - bool: A flag indicating whether the build mode is supported on Unix-based platforms.
@(private="file")
get_unix_ext :: proc(mode: string) -> (string, bool) {
    switch mode {
        case "", "exe", "test":
            return "", true
        case "dll", "shared", "dynamic":
            return ".so", true
        case "lib", "static":
            return ".a", true
        case "obj", "object":
            return ".o", true
        case "assembly", "assembler", "asm":
            return ".s", true
        case "llvm-lr", "llvm":
            return ".ll", true
    }

    return "", false
}

// Returns the appropriate file extension for macOS based on the build mode.
//
// Parameters:
// - mode: The build mode (e.g., "exe", "dll", "static", etc.).
//
// Returns:
// - string: The file extension for the given build mode on macOS.
// - bool: A flag indicating whether the build mode is supported on macOS.
@(private="file")
get_mac_ext :: proc(mode: string) -> (string, bool) {
    switch mode {
        case "", "exe", "test":
            return "", true
        case "dll", "shared", "dynamic":
            return ".dylib", true
        case "lib", "static":
            return ".a", true
        case "obj", "object":
            return ".o", true
        case "assembly", "assembler", "asm":
            return ".s", true
        case "llvm-lr", "llvm":
            return ".ll", true
    }

    return "", false
}

// Returns the appropriate file extension based on the target architecture and build type.
//
// Parameters:
// - arch: The target architecture (e.g., "windows_amd64", "linux_amd64", "darwin_arm64").
// - type: The build type (e.g., "exe", "test", "dll", etc.).
//
// Returns:
// - string: The file extension for the given architecture and build type.
// - bool: A flag indicating whether the build type is supported for the specified architecture.
get_extension :: proc(arch: string, type: string) -> (string, bool) {
    platform, platform_supported := get_platform(arch)
    if !platform_supported {
        msg := fmt.aprintf("Architecture \"%s\" is not supported", arch)
        defer delete(msg)
        logger.error(msg)
        
        return "", false
    }

    ext: string = ""
    ext_ok: bool

    switch platform {
        case .Windows:
            ext, ext_ok = get_windows_ext(type)
        case .Unix:
            ext, ext_ok = get_unix_ext(type)
        case .Mac:
            ext, ext_ok = get_mac_ext(type)
        case .Unknown:
            ext_ok = false
    }

    if !ext_ok {
        msg := fmt.aprintf("Build mode \"%s\" is not supported for architecture \"%s\"", type, arch)
        logger.error(msg)
        return "", false
    }

    return ext, true
}