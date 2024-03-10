const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    add_day_target(b, "day1", target, optimize);
    add_day_target(b, "day2", target, optimize);

    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/unit_tests.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests for all days");
    test_step.dependOn(&run_unit_tests.step);
}

fn add_day_target(b: *std.build, comptime day: []const u8, target: std.zig.CrossTarget, optimize: std.builtin.OptimizeMode) void {
    const source_file = get_source_file_path(day);

    const day_exe = b.addExecutable(.{
        .name = day,
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .path = source_file },
        .target = target,
        .optimize = optimize,
    });

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(day_exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_day = b.addRunArtifact(day_exe);
    const run_step = b.step(day, "Run the day");
    run_step.dependOn(&run_day.step);
}

fn get_source_file_path(comptime day: []const u8) []const u8 {
    const prefix = "src/";
    const suffix = ".zig";
    const path = prefix ++ day ++ suffix;
    return path;
}
