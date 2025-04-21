const std = @import("std");
const parse_input = @import("parse_input.zig");
const arg_set_path = @import("arg_set.zig");
const file_init = @import("initialize_txt_file.zig");
const stdout = std.io.getStdOut().writer();

// MAYBE WANT TO MAKE NOTE LIST IN MAIN FUNC AND PASS TO HERE
// THEN YOU CAN DEALLOCATE NOTE LIST IN MAIN, THIS WAY NOT DEALLOCATING TOO EARLY

pub fn handle_input(allocator: std.mem.Allocator, file: *std.fs.File) !void {
    const stdin = std.io.getStdIn().reader();

    outer: while (true) {
        const input_buff = try stdin.readUntilDelimiterAlloc(allocator, '\n', 512);
        defer allocator.free(input_buff);

        const args = try parse_input.parse_input(allocator, input_buff);
        defer args.deinit();

        try remove_args_and_add_note(input_buff, file, allocator);
        const file_size = try file.getEndPos();
        const buffer = try allocator.alloc(u8, file_size);

        for (args.items) |arg| {
            if (std.mem.eql(u8, arg, "-done")) {
                break :outer;
            } else if (std.mem.eql(u8, arg, "-show")) {
                try file.seekTo(0);
                _ = try file.readAll(buffer);
                try stdout.print("{s}", .{buffer});
            } else if (std.mem.eql(u8, arg, "-clear")) {
                _ = try del_to_dashes(file);
            }
        }
    }
}

// remove args using new string, convert to array list, then use write to go back to string
fn remove_args_and_add_note(input: []const u8, file: *std.fs.File, allocator: std.mem.Allocator) !void {
    var arg_set = try arg_set_path.set(allocator);
    defer arg_set.deinit();

    const str_with_newline = try allocator.dupe(u8, input);
    std.mem.replaceScalar(u8, str_with_newline, '*', '\n');

    var split_iter = std.mem.splitAny(u8, str_with_newline, " ");

    while (split_iter.next()) |word| {
        if (arg_set.contains(word)) {
            return;
        }
    }
    try file.writeAll(str_with_newline);
}

fn del_to_dashes(file: *std.fs.File) !void {
    try file.seekTo(30);
    try file.setEndPos(30);
}
