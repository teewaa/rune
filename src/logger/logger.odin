package logger

import "core:fmt"

// ANSI escape codes for terminal text color formatting
@(private="file")
RESET  := "\033[0m"   // Reset the text formatting
@(private="file")
RED    := "\033[31m"  // Red color for errors
@(private="file")
GREEN  := "\033[32m"  // Green color for success messages
@(private="file")
YELLOW := "\033[33m"  // Yellow color for warnings

// Prints an error message in red to the terminal.
//
// Parameters:
// - msg: The error message to print.
error :: proc(msg: string) {
    print_msg := fmt.aprintf("%s%s%s", RED, msg, RESET)
    fmt.eprintln(print_msg)
    delete(print_msg)
}

// Prints a warning message in yellow to the terminal.
//
// Parameters:
// - msg: The warning message to print.
warn :: proc(msg: string) {
    print_msg := fmt.aprintf("%s%s%s", YELLOW, msg, RESET)
    fmt.eprintln(print_msg)
    delete(print_msg)
}

// Prints a success message in green to the terminal.
//
// Parameters:
// - msg: The success message to print.
success :: proc(msg: string) {
    print_msg := fmt.aprintf("%s%s%s", GREEN, msg, RESET)
    fmt.println(print_msg)
    delete(print_msg)
}

// Prints an informational message to the terminal.
//
// Parameters:
// - msg: The informational message to print. Defaults to an empty string if not provided.
info :: proc(msg: string = "") {
    fmt.println(msg)
}

// Prints an informational message to the terminal without a return.
//
// Parameters:
// - msg: The informational message to print. Defaults to an empty string if not provided.
infosl :: proc(msg: string = "") {
    fmt.print(msg)
}

// Prints a success message in green to the terminal without a return.
//
// Parameters:
// - msg: The success message to print.
successsl :: proc(msg: string) {
    print_msg := fmt.aprintf("%s%s%s", GREEN, msg, RESET)
    fmt.print(print_msg)
    delete(print_msg)
}

// Prints a warning message in yellow to the terminal without a return.
//
// Parameters:
// - msg: The warning message to print.
warnsl :: proc(msg: string) {
    print_msg := fmt.aprintf("%s%s%s", YELLOW, msg, RESET)
    fmt.eprint(print_msg)
    delete(print_msg)
}

// Prints an error message in red to the terminal without a return.
//
// Parameters:
// - msg: The error message to print.
errorsl :: proc(msg: string) {
    print_msg := fmt.aprintf("%s%s%s", RED, msg, RESET)
    fmt.eprint(print_msg)
    delete(print_msg)
}
