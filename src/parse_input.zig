//              This funtion takes an input buffer i.e. what the user in typing into the terminal
//              and picks out what arguments are in the input. Then it returns a list of all the
//              special args (*, -done, -show, -del etc.) to be used in other functions

const std = @import("std");
const stdout = std.io.getStdOut().writer();
const arg_set_path = @import("arg_set.zig");

pub fn parse_input(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList([]const u8) {
    // Get our set of args that the user could use
    var arg_set = try arg_set_path.set(allocator);
    defer arg_set.deinit();

    // Break down the input (what the user typed into the terminal into individual words
    var tokens = std.mem.tokenizeScalar(u8, input, ' ');

    var arg_list = std.ArrayList([]const u8).init(allocator);

    // loop through the tokens and get all the args
    while (tokens.next()) |arg| {
        if (arg_set.contains(arg)) {
            //try stdout.print("match, contains {s}\n", .{arg});
            try arg_list.append(arg);
        }
    }

    return arg_list;
}
