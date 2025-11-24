package main

print_help :: proc() {
    log_info("rune - A build tool for the Odin programming language");
    log_info("");
    log_info("Usage:");
    log_info("  rune command> [options]");
    log_info("");
    log_info("Commands:");
    log_info("  new [build-mode] <target>        Create a new rune.json file with the given build mode and output target.");
    log_info("                                   Example: rune new debug bin/my_app");
    log_info("");
    log_info("  test [profile] -t:<test> -f:<file> -p:<package>");  
    log_info("                                  Run tests for the project. If no profile is specified, uses the default in rune.json.");
    log_info("                                  -t:<test>    Run a specific test by name.");
    log_info("                                  -f:<file>    Run tests from a specific file.");
    log_info("                                  -p:<package> Run tests from a specific package.");
    log_info("                                  Example: rune test debug -t:math_addition -f:math.odin");
    log_info("");
    log_info("  run [profile]          Compile and run the executable for a given profile.");
    log_info("                                  If no profile is given, uses the default profile in rune.json.");
    log_info("                                  Example: rune run");
    log_info("                                           rune run release");
    log_info("");
    log_info("  build [profile]        Compile the project using a given profile. Defaults to the one set in rune.json.");
    log_info("                                  Example: rune build debug");
    log_info("");
    log_info("  [script]               Executes a script listed in rune.json.");
    log_info("                                  If no script is given, returns an error messagen.");
    log_info("                                  Example: rune clean");
    log_info("                                           rune deploy");
    log_info("")
    log_info("  version                         Prints the version of rune.");
    log_info("  -h, --help                      Prints this help message.");
    log_info("  -v, --verbose                   Prints the command being ran.");
    log_info("");
    log_info("Project files:");
    log_info("  rune.json                       Defines profiles, default profile, and scripts for the project.");
    log_info("");
    log_info("Examples:");
    log_info("  rune new exe -o:app             Create a rune.json file with an executable called app");
    log_info("  rune test                       Run tests using the default profile");
    log_info("  rune run                        Run the executable using the default profile");
}
