const std = @import("std");
const testing = std.testing;
const expect = testing.expect;

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
