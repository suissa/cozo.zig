const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("cozo", .{
        .root_source_file = b.path("src/cozo.zig"),
        .target = target,
        .optimize = optimize,
    });

    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/cozo.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    tests.addCSourceFile(.{ .file = b.path("test/mock_cozo.c") });
    tests.linkLibC();

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run the Cozo client tests");
    test_step.dependOn(&run_tests.step);
}
