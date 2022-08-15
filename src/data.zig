const std = @import("std");

pub const PrimitiveData = union(enum) {
    String: []const u8,
};
