package cmds

import "core:fmt"
import "core:strings"
import "rune:utils"

// process_script handles the `rune [script]` command.
//
// It uses the provided `args` to determine which script to run.
// If no script is explicitly provided, it returns an error message.
//
// Parameters:
// - sys:    The system abstraction used to interact with the OS or shell.
// - args:   Command-line arguments passed to `rune build`.
// - schema: Parsed rune.json configuration containing profiles and settings.
//
// Returns:
// - success: A success message string, if the script completes successfully.
// - err:     An error message string, if something goes wrong.
process_script :: proc(sys: utils.System, args: []string, schema: utils.Schema) -> (string, string) {
    script: string
    for key in schema.scripts {
        if key == args[0] {
            script = schema.scripts[key]
            break
        }
    }

    if script == "" {
        return "", fmt.aprintf("Script %s doesn't exists", args[0])
    }

    script_err := utils.execute_script_with_logs(sys, script)

    if script_err != "" {
        return "", script_err
    }

    return strings.clone("Successfully executed script"), ""
}