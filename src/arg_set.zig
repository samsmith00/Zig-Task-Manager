/// Creates a set with all the args the user might input
/// This way we are able to determine which args the user uses
/// Can also create a subset which are exatly the args the user is using, does not contain all the args
const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn set(allocator: std.mem.Allocator) !std.BufSet {
    var arg_set = std.BufSet.init(allocator);

    const args = [_][]const u8{ "-done", "-del", "-show", "-p", "*", "-clear", "-x", "-s"};

    for (args) |arg| {
        try arg_set.insert(arg);
    }

    return arg_set;
}

pub fn create_subset(allocator: std.mem.Allocator, args: std.ArrayList([]const u8)) !std.BufSet {
    var subset = std.BufSet.init(allocator);
    for (args.items) |arg| {
        try subset.insert(arg);
    }
    return subset;
}
