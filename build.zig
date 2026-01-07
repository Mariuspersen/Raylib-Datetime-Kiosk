const std = @import("std");
const rl = @import("raylib");
const Config = @import("build.zig.zon");

const opts: rl.Options = .{
    .raudio = Config.raudio,
    .rmodels = Config.rmodels,
    .rshapes = Config.rshapes,
    .rtext = Config.rtext,
    .rtextures = Config.rtextures,
    .platform = Config.platform,
    .linkage = Config.linkage,
    .linux_display_backend = Config.linux_display_backend,
    .opengl_version = Config.opengl_version,
    .android_ndk = Config.android_ndk,
    .android_api_version = Config.android_api_version,
    .config = Config.config,
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const raylib_dep = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
        .raudio = opts.raudio,
        .rmodels = opts.rmodels,
        .rshapes = opts.rshapes,
        .rtext = opts.rtext,
        .rtextures = opts.rtextures,
        .platform = opts.platform,
        .linkage = opts.linkage,
        .linux_display_backend = opts.linux_display_backend,
        .opengl_version = opts.opengl_version,
        .android_ndk = opts.android_ndk,
        .android_api_version = opts.android_api_version,
        .config = opts.config,
    });
    const raylib = raylib_dep.artifact("raylib");
    const root = b.addModule("root", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const exe = b.addExecutable(.{
        .name = "main",
        .root_module = root,
    });
    exe.root_module.linkLibrary(raylib);
    b.installArtifact(exe);
}
