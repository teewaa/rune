package main

SCHEMA_PATH :: "https://raw.githubusercontent.com/ametyx/rune/refs/heads/main/misc/rune.1.0.x.json"

CopyAction :: struct {
    to:     string                                  `json:"to"`,
    from:   string                                  `json:"from"`
}

SchemaBuildStep :: struct {
    copy:       []CopyAction                        `json:"copy"`,
    scripts:    []string                            `json:"scripts"`,
}

SchemaProfile :: struct {
    name:       string                              `json:"name"`,
    target:     string                              `json:"target"`,
    output:     string                              `json:"output"`,
    arch:       string                              `json:"arch"`,
    entry:      string                              `json:"entry"`,
    flags:      [dynamic]string                     `json:"build_flags"`,
    pre_build:  SchemaBuildStep                     `json:"pre_build"`,
    post_build: SchemaBuildStep                     `json:"post_build"`,
    build_mode: string                              `json:"build_mode"`,
}

ExecuteAction :: distinct []string

Schema :: struct {
    default_profile:        string                  `json:"default_profile"`,
    default_test_profile:   string                  `json:"default_test_profile"`,
    profiles:               []SchemaProfile         `json:"profiles"`,
    scripts:                map[string]string       `json:"scripts"`,
    version:                string                  `json:"version"`
}

SchemaJsonProfile :: struct {
    name:       string                              `json:"name"`,
    target:     string                              `json:"target"`,
    output:     string                              `json:"output"`,
    arch:       string                              `json:"arch"`,
    entry:      string                              `json:"entry"`,
    build_mode: string                              `json:"build_mode"`,
}

SchemaJson :: struct {
    schema:                 string                  `json:"$schema"`,
    default_profile:        string                  `json:"default_profile"`,
    profiles:               []SchemaJsonProfile     `json:"profiles"`,
    version:                string                  `json:"version"`
}