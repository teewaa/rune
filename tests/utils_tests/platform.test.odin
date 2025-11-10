package utils_tests

import "core:fmt"
import "core:testing"
import "rune:utils"

@(test)
return_windows_platforms :: proc(t: ^testing.T) {
    arr := []string{ "windows_i386", "windows_amd64" }

    for arch in arr {
        plat, _ := utils.get_platform(arch)
        msg := fmt.aprintf("Invalid platform, received %s expected :%s", plat, utils.Platform.Windows)
        defer delete(msg)
        testing.expect(t, plat == utils.Platform.Windows, msg)
    }
}

@(test)
return_unix_platforms :: proc(t: ^testing.T) {
    arr := []string{ "linux_i386", "linux_amd64", "linux_arm64", "linux_arm32", "linux_riscv64",
            "freebsd_i386", "freebsd_amd64", "freebsd_arm64", 
            "netbsd_amd64", "netbsd_arm64", 
            "openbsd_amd64", "haiku_amd64", 
            "freestanding_wasm32", "wasi_wasm32", "js_wasm32", "orca_wasm32",
            "freestanding_wasm64p32", "js_wasm64p32", "wasi_wasm64p32", 
            "freestanding_amd64_sysv", "freestanding_amd64_win64", 
            "freestanding_arm64", "freestanding_arm32", "freestanding_riscv64" }

    for arch in arr {
        plat, _ := utils.get_platform(arch)
        msg := fmt.aprintf("Invalid platform, received %s expected :%s", plat, utils.Platform.Unix)
        defer delete(msg)
        testing.expect(t, plat == utils.Platform.Unix, msg)
    }
}

@(test)
return_mac_platforms :: proc(t: ^testing.T) {
    arr := []string{ "darwin_amd64", "darwin_arm64" }

    for arch in arr {
        plat, _ := utils.get_platform(arch)
        msg := fmt.aprintf("Invalid platform, received %s expected :%s", plat, utils.Platform.Mac)
        defer delete(msg)
        testing.expect(t, plat == utils.Platform.Mac, msg)
    }
}

@(test)
return_unknown_platform :: proc(t: ^testing.T) {
    plat, _ := utils.get_platform("invalid")
    msg := fmt.aprintf("Invalid platform, received %s expected :%s", plat, utils.Platform.Unknown)
    defer delete(msg)
    testing.expect(t, plat == utils.Platform.Unknown, msg)
}