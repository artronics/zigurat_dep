const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;
const expect = testing.expect;

pub fn Template() type {
    return struct {
        const Self = @This();

        alloc: Allocator,
        path: []const u8,
        buf: []u8,

        pub fn init(allocator: Allocator, path: []const u8) !Self {
            var v = try allocator.alloc(u8, 10);

            return Self{ .alloc = allocator, .path = path, .buf = v };
        }
        pub fn deinit(self: Self) void {
            self.alloc.free(self.buf);
        }

        pub fn parse(self: *Self) !void{}
    };
}

test "init" {
    var s = try Template().init(testing.allocator, "yo");
    _ = try std.fs.cwd().openFile("./zig-out/bin/yo", .{});
    defer s.deinit();
    try expect(s.path[0] == 'y');
}

test "path" {
    var buf:[100]u8 = undefined;
    var s: []u8 = buf[0..];
    const ff = try std.fs.cwd().realpath("./zig-out/bin/yo", s);
    std.log.warn("abs {s}", .{ff}); // get the abs part from rel part

    try expect(std.fs.path.isAbsolute(ff));
    try expect(!std.fs.path.isAbsolute("./zig-out/bin/yo"));

    const d = std.fs.path.dirname("./zig-out/bin").?; // not working; strip out the /bin part
    std.log.warn("dirname {s}", .{d});
    const kk = try std.fs.createFileAbsolute(ff, .{});
    const md = try kk.metadata();
    std.log.warn("dirname2 {s}", .{@tagName(md.kind())}); // File
}

test "file size" {
    var tmp_dir = testing.tmpDir(.{}); // This creates a directory under ./zig-cache/tmp/{hash}/test_file
    defer tmp_dir.cleanup(); // commented out this line so, you can see the file after execution finished.

    var file1 = try tmp_dir.dir.createFile("test_file", .{ .read = true });
    defer file1.close();

    const write_buf: []const u8 = "Hello Zig!";
    try file1.writeAll(write_buf);

    try expect(file1.getEndPos() catch 0 == 10);
}

test "create a file and then open and read it" {
    var tmp_dir = testing.tmpDir(.{}); // This creates a directory under ./zig-cache/tmp/{hash}/test_file
    defer tmp_dir.cleanup(); // commented out this line so, you can see the file after execution finished.

    var file1 = try tmp_dir.dir.createFile("test_file", .{ .read = true });
    defer file1.close();

    const write_buf: []const u8 = "Hello Zig!";
    try file1.writeAll(write_buf);

    var file2 = try tmp_dir.dir.openFile("test_file", .{});
    defer file2.close();

    const read_buf = try file2.readToEndAlloc(testing.allocator, 1024);
    defer testing.allocator.free(read_buf);

    try testing.expect(std.mem.eql(u8, write_buf, read_buf));
}
