package main

import "core:fmt"

@(private="file")
RESET  := "\033[0m"
@(private="file")
RED    := "\033[31m"
@(private="file")
GREEN  := "\033[32m"
@(private="file")
YELLOW := "\033[33m"

log_error :: proc(msg: string) {
    print_msg := fmt.aprintf("%s%s%s", RED, msg, RESET)
    fmt.eprintln(print_msg)
    delete(print_msg)
}

log_warn :: proc(msg: string) {
    print_msg := fmt.aprintf("%s%s%s", YELLOW, msg, RESET)
    fmt.eprintln(print_msg)
    delete(print_msg)
}

log_success :: proc(msg: string) {
    print_msg := fmt.aprintf("%s%s%s", GREEN, msg, RESET)
    fmt.println(print_msg)
    delete(print_msg)
}

log_info :: proc(msg: string = "") {
    fmt.println(msg)
}

log_infosl :: proc(msg: string = "") {
    fmt.print(msg)
}

log_successsl :: proc(msg: string) {
    print_msg := fmt.aprintf("%s%s%s", GREEN, msg, RESET)
    fmt.print(print_msg)
    delete(print_msg)
}

log_warnsl :: proc(msg: string) {
    print_msg := fmt.aprintf("%s%s%s", YELLOW, msg, RESET)
    fmt.eprint(print_msg)
    delete(print_msg)
}

log_errorsl :: proc(msg: string) {
    print_msg := fmt.aprintf("%s%s%s", RED, msg, RESET)
    fmt.eprint(print_msg)
    delete(print_msg)
}
