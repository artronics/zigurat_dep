const std = @import("std");
const testing = std.testing;
const expect = testing.expect;
const warn = std.log.warn;

const tmp = @import("lib.zig");

test "test" {
    var buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const path = try createTestFile("yo", "This is a test {{ foo }}\nThis is the second line {{ foo }}", buffer[0..]);
    var t = try tmp.Template().init(testing.allocator, path);
    defer t.deinit();
    const outBuf = try t.parse();
    try expect(std.mem.eql(u8, outBuf, "This is a test bar\nThis is the second line bar"));
    warn("dir {s}", .{path});
}


fn createTestFile(name: []const u8, content: []const u8, outPath: []u8) ![]u8 {
    var tmp_dir = testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    var f = try tmp_dir.dir.createFile(name, .{ .read = true });
    defer f.close();

    const buf: []const u8 = content;
    try f.writeAll(buf);

    return try tmp_dir.dir.realpath(name, outPath);
}
