const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const raylib_dep = b.dependency("raylib", .{
        .optimize = optimize,
        .target = target,
    });
    const raylib = raylib_dep.module("raylib");
    const mod = b.addModule("raygui", .{
        .link_libc = true,
        .imports = &.{.{ .name = "raylib", .module = raylib }},
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    mod.addIncludePath(b.path("raygui/src"));
    const lib = b.addStaticLibrary(.{
        .name = "raygui",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    lib.addCSourceFile(.{
        .file = b.path("raygui/src/raygui.h"),
        .flags = &.{
            "-DRAYGUI_IMPLEMENTATION",
        },
    });
    lib.linkLibrary(raylib_dep.artifact("raylib"));
    lib.addIncludePath(b.path("raygui/src/"));
    b.installArtifact(lib);
}
