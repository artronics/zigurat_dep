const std = @import("std");
const Allocator = std.mem.Allocator;
const StringHashMap = std.StringHashMap;
const warn = std.log.warn;

pub const Record = union(enum) {
    const Self = @This();

    String: []const u8,
    Boolean: bool,

    pub fn eql(self: Self, other: Record) bool {
        const sameTag = std.mem.eql(u8, @tagName(self), @tagName(other));
        return sameTag and switch (self) {
            .String => |v| std.mem.eql(u8, v, other.String),
            .Boolean => |v| v == other.Boolean,
        };
    }
};

var db: StringHashMap(Record) = undefined;

pub fn init(_allocator: Allocator) !void {
    db = StringHashMap(Record).init(_allocator);

    // TODO: uncomment these to use actual cl args
    // var args = try std.process.argsAlloc(allocator);
    // defer allocator.free(a);
    var args = [_][]const u8{ "yo", "foo", "--var", "hey=false", "-v", "lol=\"hey hey\"", "--var" };

    var i: usize = 0;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--var") or std.mem.eql(u8, args[i], "-v")) {
            const v = i + 1; // value index for --var
            if (v == args.len) break; // make sure --var is not the last one

            var it = std.mem.split(u8, args[v], "=");
            const key = it.first();
            const value = it.rest();
            // TODO: parse value
            try db.put(key, Record{.String = value});

            i += 1; // consume value
        }
    }
}

pub fn deinit() void {
    db.deinit();
}

const testing = std.testing;
const expect = std.testing.expect;

test "readData" {
    {
        try init(testing.allocator);
        defer deinit();
    }
}
