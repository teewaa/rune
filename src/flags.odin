package main

import "core:strings"

BUILD               :: "build"
NEW                 :: "new"
RUN                 :: "run"
TEST                :: "test"
HELP                :: "help"
HELP_SHORT          :: "h"
DEFAULT_FLAG_VAL    :: "true"

Parsed_Args :: struct {
    flags: map[string]string,
    positionals: [dynamic]string,
}

parse_args :: proc(argv: []string) -> Parsed_Args {
    parsed := Parsed_Args{
        flags = make(map[string]string),
        positionals = make([dynamic]string),
    }
    
    for i := 1; i < len(argv); i += 1 {
        token := argv[i]
        
        if strings.has_prefix(token, "--") && len(token) > 2 {
            key := token[2:]
            
            colon_index := strings.index_byte(key, ':')
            if colon_index != -1 {
                actual_key := key[:colon_index]
                value := key[colon_index + 1:]
                parsed.flags[actual_key] = value
            } else {
                parsed.flags[key] = DEFAULT_FLAG_VAL
            }
        } else if strings.has_prefix(token, "-") && len(token) > 1 {
            without_dash := token[1:]
            colon_index := strings.index_byte(without_dash, ':')
            
            if colon_index != -1 {
                key := without_dash[:colon_index]
                value := without_dash[colon_index + 1:]
                parsed.flags[key] = value
            } else {
                parsed.flags[without_dash] = DEFAULT_FLAG_VAL
            }
        } else {
            append(&parsed.positionals, token)
        }
    }
    
    return parsed
}

destroy_args :: proc(parsed: ^Parsed_Args) {
    delete(parsed.flags)
    delete(parsed.positionals)
}