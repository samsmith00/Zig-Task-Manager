const std = @import("std");
const banner = @import("banner.zig");
const handle_input = @import("input.zig");
const file_init = @import("initialize_txt_file.zig");

const stdout = std.io.getStdOut().writer();

/// Tasks to complete
///     1. make delete notes function
///     2. make priority (some how to write to top of file)
///     3. delete individual tasks
///     4.
///
///
pub const Notes = struct {
    id: u32,
    content: []const u8,
    allocator: std.mem.Allocator,

    pub fn init(num: u32, str: []const u8, allocator: std.mem.Allocator) Notes {
        return Notes{ .id = num, .content = str, .allocator = allocator };
    }

    pub fn _display(self: Notes) !void {
        try stdout.print("{d}. ", .{self.id});
        try stdout.print("{s}", .{self.content});
    }

    pub fn _format_for_file(self: Notes) ![] u8 {
        const id_as_str = try std.fmt.allocPrint(self.allocator, "{d}", .{self.id});
        var message_builder = std.ArrayList(u8).init(self.allocator);
        try message_builder.appendSlice(id_as_str);
        try message_builder.appendSlice(". ");
        try message_builder.appendSlice(self.content);

        const message = try message_builder.toOwnedSlice();
        return message;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // TRYING TO SEE IF JUST INITIALIZING FILE IN HANDLE INPUT IS
    
    var note_list = std.ArrayList(Notes).init(allocator);

    defer {
        //file.close();
        note_list.deinit();
    }

    try banner.run_banner();
    try handle_input.handle_input(allocator, &note_list);
}
