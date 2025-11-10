package cmds

import "rune:logger"

// print_help outputs the usage and available commands for the `rune` CLI tool.
//
// This function is called when the user invokes `rune -h` or `rune --help`.
// It prints a structured list of commands, options, and examples to guide the user.
//
// Each logger.info call prints a specific line of the help message to the terminal.
// The help text includes supported commands such as `new`, `build`, `test`, `run`,
// and general flags like `--version` and `--help`.
print_help :: proc() {
    logger.info("rune - A build profile tool for the Odin programming language");
    logger.info("");
    logger.info("Usage:");
    logger.info("  rune command> [options]");
    logger.info("");
    logger.info("Commands:");
    logger.info("  new [build-mode] <target>        Create a new rune.json file with the given build mode and output target.");
    logger.info("                                   Example: rune new debug bin/my_app");
    logger.info("");
    logger.info("  test [profile] -t:<test> -f:<file> -p:<package>");  
    logger.info("                                  Run tests for the project. If no profile is specified, uses the default in rune.json.");
    logger.info("                                  -t:<test>    Run a specific test by name.");
    logger.info("                                  -f:<file>    Run tests from a specific file.");
    logger.info("                                  -p:<package> Run tests from a specific package.");
    logger.info("                                  Example: rune test debug -t:math_addition -f:math.odin");
    logger.info("");
    logger.info("  run [profile]          Compile and run the executable for a given profile.");
    logger.info("                                  If no profile is given, uses the default profile in rune.json.");
    logger.info("                                  Example: rune run");
    logger.info("                                           rune run release");
    logger.info("");
    logger.info("  build [profile]        Compile the project using a given profile. Defaults to the one set in rune.json.");
    logger.info("                                  Example: rune build debug");
    logger.info("");
    logger.info("  [script]               Executes a script listed in rune.json.");
    logger.info("                                  If no script is given, returns an error messagen.");
    logger.info("                                  Example: rune clean");
    logger.info("                                           rune deploy");
    logger.info("")
    logger.info("  version                         Prints the version of rune.");
    logger.info("  -h, --help                      Prints this help message.");
    logger.info("  -v, --version                   Prints the command being ran.");
    logger.info("");
    logger.info("Project files:");
    logger.info("  rune.json                       Defines profiles, default profile, and scripts for the project.");
    logger.info("");
    logger.info("Examples:");
    logger.info("  rune new release bin/app        Create a rune.json with a 'release' profile targeting bin/app");
    logger.info("  rune test                       Run tests using the default profile");
    logger.info("  rune run                        Run the executable using the default profile");
}
