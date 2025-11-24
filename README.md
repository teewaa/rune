# Rune

```Disclaimer:``` Rune is still in its early phases. As I'm developing personal projects with it, I am making modifications. As of now, any 0.X version is a breaking change. The breaking changes can be seen in the release's changelog. If the Rune.json schema changes, you may need to upgrade the schema path to use the correct 0.X version.

**Rune** is a profile based build system for [Odin](https://odin-lang.org/) projects. It lets you define and automate build steps and gives you an easy interface to test your projects.

## Features

- **Explicit Build Definitions** – The profiles and build steps are defined in the `rune.json` file.
- **Multi-profile Support** – Build for multiple architectures easily.
- **Script Hooks** – Add pre/post build behavior with reusable named scripts.
- **Targets, Custom Outputs & Flags** – Each profile has it's own target, output and flags, allowing you to have multiple Odin projects within the same repository.

## Installation

To install Rune, you can either download the source code from one of the releases or clone the repository by running ```git clone https://github.com/DavidAlexLapierre/rune.git```. I suggested always picking the latest release since it will have the appropriate version.

Once you have the source code, run the follow command to build the project in your terminal

```sh
# On Windows and from the root directory
./scripts/build.bat

# On Linux/MacOS from the root directory
./scripts/build.sh
```

**Warning:** You may need to run the command `chmod +x ./scripts/build.sh` on linux and macos.

**Note**: Once the project is built, either copy the executable to another directory or leave it as is. After that, add the path of the executable to your PATH `{root}/bin/`.

## Usage

**Help**

```txt
rune - A build tool for the Odin programming language

Usage:
  rune command> [options]

Commands:
  new [build-mode] <target>        Create a new rune.json file with the given build mode and output target.
                                   Example: rune new debug bin/my_app

  test [profile] -t:<test> -f:<file> -p:<package>
                                  Run tests for the project. If no profile is specified, uses the default in rune.json.
                                  -t:<test>    Run a specific test by name.
                                  -f:<file>    Run tests from a specific file.
                                  -p:<package> Run tests from a specific package
                                  Example: rune test debug -t:math_addition -f:math.odin

  run [profile?]          Compile and run the executable for a given profile.
                                  If no profile is given, uses the default profile in rune.json.
                                  Example: rune run
                                           rune run release

  build [profile]         Compile the project using a given profile. Defaults to the one set in rune.json.
                                  If no profile is given, uses the default profile in rune.json.
                                  Example: rune build debug
  
  [script]                Executes a script listed in rune.json.
                                  If no script is given, returns an error message.
                                  Example: rune clean
                                          rune deploy

  version                         Prints the version of rune.
  -h, --help                      Prints this help message.
  -v, --verbose                   Prints the command being ran.

Project files:
  rune.json                       Defines profiles, default profile, and scripts for the project.

Examples:
  rune new exe -o:app             Create a rune.json file with an executable called app
  rune test                       Run tests using the default profile
  rune run                        Run the executable using the default profile
```

**New**

Create a new rune.json file with the given build mode and output target.

```sh
# Usage
rune new [build-mode] -o:<target>

# E.g. Create an executable called my_project
rune new exe -o:my_project

# E.g. Create a dynamic library with the name of the parent directory
rune new dynamic
```

**Build**

Compile the project using a given profile. Defaults to the profile specified in `configs.profile`.

```sh
# Usage
rune build [profile?]

# Build the profile set as default
rune build

# E.g. Builds the profile called debug
rune build debug

# E.g. Builds the profile called release
rune build release
```

**Test**

Run tests given a profile with the option of targeting a specific file or a single test. Defaults
to the profile specified in `configs.test_profile`.

```sh
# Usage
rune test [profile?] -t:<test_name> -f:<file_name>

# Run the test profile set as default
rune test

# E.g. Run a specific test profile
rune test my_test_profile

# E.g. Test a specific file according to the release profile
rune test release -f:./path/to/my/file.odin

# E.g. Run a specific test
rune test -t:name_of_my_test_procedure

# E.g. Run a specific package
rune test -p:my_package
```

**Run**

Compiles and run a project given a profile. Defaults to `configs.profile`. Can only be used for
executable projects.

```sh
# Usage
rune run [profile?]

# Runs the profile set as default
rune run

# E.g. Runs the profile called debug
rune run debug

# E.g. Runs profile called release
rune run release
```

**Scripts**

If you listed a script in your rune.json, you can call it in pre-build or post-build but you can also
directly call it from rune.

```sh
# In your rune.json
# ...
# scripts: {
#   "clean": "py ./scripts/clean.py"
# }
#...

# Usage
rune clean

# You can also add scripts to pre and post build steps
# ...
# profiles: [
#   {
#     "name": "default",
#     ...
#     "post_build": {
#       "scripts": [
#         "clean"
#       ]
#     }
#   }
#]
```

**Copy action**

Rune also comes built-in with a copy action in either the pre or post build step. This means you can easily copy any files or directory before or after your build, which can be useful in scenarios like copying game assets to your release directory.

```
profiles: [
  {
    "name": "default",
    "output": "bin/{config}/{arch}/"
    ...
    "pre_build": {
      "copy": [
        { "from": "assets/", "to": "assets/" }
      ]
    }
  }
]
```

In this case, `from` looks for directories where `./` is the location if your rune.json and `to` points the output directory specified in your profile. In the example above, the assets located in `{root}/assets/` would be copied to `{root}/bin/{config}/{arch}/assets/`.

## Misc information

- You can use the following values in the output path to dynamically change the path based on the profile
  - `{config}`: Will take the value of release or debug, based on whether the profile has the `--debug` flag.
  - `{arch}`: The architecture used by the profile.
  - `{profile}`: The name of the profile.
  - E.g: You can use the output `bin/{config}/{arch}/` which could create a `bin/debug/windows_amd64/` output directory on windows.