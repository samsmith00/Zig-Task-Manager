const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn set(allocator: std.mem.Allocator) !std.BufSet {
    var arg_set = std.BufSet.init(allocator);

    const args = [_][]const u8{ "-done", "-del", "-show", "-p", "*", "-clear", "-x"};

    for (args) |arg| {
        try arg_set.insert(arg);
    }

    return arg_set;
}
