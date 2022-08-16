const std = @import("std");
const Allocator = std.mem.Allocator;
const warn = std.log.warn;

pub fn Template() type {
    return struct {
        const Self = @This();

        allocator: Allocator,
        path: []const u8,
        content: []const u8,

        pub fn init(allocator: Allocator, path: []const u8) !Self {
            const content = try openFile(allocator, path);

            return Self{
                .allocator = allocator,
                .path = path,
                .content = content,
            };
        }

        pub fn deinit(self: Self) void {
            self.allocator.free(self.content);
        }

        pub fn parse(self: *Self) ![]const u8 {
            // TODO: add parser
            return self.content;
        }

        pub fn output(self: *Self) ![]const u8 {
            // TODO: return final buffer
            return self.content;
        }
    };
}

pub fn openFile(allocator: Allocator, path: []const u8) ![]const u8 {
    var pathBuf: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    var file: std.fs.File = undefined;

    if (std.fs.path.isAbsolute(path)) {
        file = try std.fs.openFileAbsolute(path, .{ .mode = std.fs.File.OpenMode.read_only });
    } else {
        const absPath = try std.fs.cwd().realpath(path, pathBuf[0..]);
        file = try std.fs.openFileAbsolute(absPath, .{ .mode = std.fs.File.OpenMode.read_only });
    }

    defer file.close();

    return try file.readToEndAlloc(allocator, try file.getEndPos());
}

const testing = std.testing;
const expect = testing.expect;

test "template" {
    var tmp_dir = testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    var buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const path = try createTestFile(tmp_dir, "test.template", "hello {{ world }}", buffer[0..]);
    warn("test file {s}", .{path});

    var t = try Template().init(testing.allocator, path);
    defer t.deinit();
    warn("test file content {s}", .{try t.output()});
}

fn createTestFile(dir: testing.TmpDir, name: []const u8, content: []const u8, outPath: []u8) ![]u8 {
    var f = try dir.dir.createFile(name, .{ .read = true });
    defer f.close();

    const buf: []const u8 = content;
    try f.writeAll(buf);

    return try dir.dir.realpath(name, outPath);
}
