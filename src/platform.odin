package main

import "core:fmt"

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

get_platform :: proc(arch: string) -> (Platform, Error) {
    switch arch {
        case "windows_i386", "windows_amd64":
            return .Windows, nil
        case "linux_i386", "linux_amd64", "linux_arm64", "linux_arm32", "linux_riscv64",
            "freebsd_i386", "freebsd_amd64", "freebsd_arm64", 
            "netbsd_amd64", "netbsd_arm64", 
            "openbsd_amd64", "haiku_amd64", 
            "freestanding_wasm32", "wasi_wasm32", "js_wasm32", "orca_wasm32",
            "freestanding_wasm64p32", "js_wasm64p32", "wasi_wasm64p32", 
            "freestanding_amd64_sysv", "freestanding_amd64_win64", 
            "freestanding_arm64", "freestanding_arm32", "freestanding_riscv64":
           return .Unix, nil
        case "darwin_amd64", "darwin_arm64":
            return .Mac, nil
    }

    return .Unknown, .INVALID_PLATFORM
}

@(private="file")
get_windows_ext :: proc(mode: string) -> (string, Error) {
    switch mode {
        case "", "exe", "test":
            return ".exe", nil
        case "dll", "shared", "dynamic":
            return ".dll", nil
        case "lib", "static":
            return ".lib", nil
        case "obj", "object":
            return ".obj", nil
        case "assembly", "assembler", "asm":
            return ".asm", nil
        case "llvm-lr", "llvm":
            return ".ll", nil
    }

    return "", .INVALID_EXTENSION
}

@(private="file")
get_unix_ext :: proc(mode: string) -> (string, Error) {
    switch mode {
        case "", "exe", "test":
            return "", nil
        case "dll", "shared", "dynamic":
            return ".so", nil
        case "lib", "static":
            return ".a", nil
        case "obj", "object":
            return ".o", nil
        case "assembly", "assembler", "asm":
            return ".s", nil
        case "llvm-lr", "llvm":
            return ".ll", nil
    }

    return "", .INVALID_EXTENSION
}

@(private="file")
get_mac_ext :: proc(mode: string) -> (string, Error) {
    switch mode {
        case "", "exe", "test":
            return "", nil
        case "dll", "shared", "dynamic":
            return ".dylib", nil
        case "lib", "static":
            return ".a", nil
        case "obj", "object":
            return ".o", nil
        case "assembly", "assembler", "asm":
            return ".s", nil
        case "llvm-lr", "llvm":
            return ".ll", nil
    }

    return "", .INVALID_EXTENSION
}

get_extension :: proc(arch: string, type: string) -> (string, Error) {
    platform, platform_err := get_platform(arch)
    if platform_err != nil {
        fmt.eprintfln("Architecture \"%s\" is not supported", arch)
        return "", platform_err
    }

    ext: string = ""
    ext_err: Error

    switch platform {
        case .Windows:
            ext, ext_err = get_windows_ext(type)
        case .Unix:
            ext, ext_err = get_unix_ext(type)
        case .Mac:
            ext, ext_err = get_mac_ext(type)
        case .Unknown:
            ext_err = .INVALID_EXTENSION
    }

    if ext_err != nil {
        fmt.eprintfln("Build mode \"%s\" is not supported for architecture \"%s\"", type, arch)
        return "", ext_err
    }

    return ext, nil
}