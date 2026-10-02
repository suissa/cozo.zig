const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("cozo", .{
        .root_source_file = b.path("src/cozo.zig"),
        .target = target,
        .optimize = optimize,
    });

    const tests = b.addTest(.{
        .root_source_file = b.path("tests/cozo_test.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "cozo", .module = module }},
    });
    tests.addIncludePath(b.path("native"));
    tests.addLibraryPath(b.path("native"));
    tests.linkLibC();
    tests.linkSystemLibrary("cozo_c");

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run CozoDB and ecommerce integration tests");
    test_step.dependOn(&run_tests.step);
}
