const std = @import("std");
const banner = @import("banner.zig");
const handle_input = @import("input.zig");
const file_init = @import("initialize_txt_file.zig");

const stdout = std.io.getStdOut().writer();

/// Tasks to complete
///     1. make delete notes function ✅
///     -----------------------------------------------------------------
///    | 1.5 Fix note file, right now notes go away after function closes |
///     -----------------------------------------------------------------
///     2. make priority (some how to write to top of file)
///     3. delete individual tasks
///     4.
///
pub const Notes = struct {
    id: u32,
    content: []const u8,
    allocator: std.mem.Allocator,
    status: bool,

    pub fn init(num: u32, str: []const u8, allocator: std.mem.Allocator, is_complete: bool) Notes {
        return Notes{ .id = num, .content = str, .allocator = allocator, .status = is_complete};
    }

    pub fn _display(self: Notes) !void {
        try stdout.print("{d}. ", .{self.id});
        try stdout.print("{s}", .{self.content});
    }

    pub fn _format_for_file(self: Notes) ![]u8 {
        // only use id_as_str if you want numbers for notes insted of checkboxes
        //const id_as_str = try std.fmt.allocPrint(self.allocator, "{d}", .{self.id});
        var message_builder = std.ArrayList(u8).init(self.allocator);
        defer message_builder.deinit();

        const status = if (self.status) "[X] " else "[ ] ";
        try message_builder.appendSlice(status);
        //try message_builder.appendSlice(". ");
        try message_builder.appendSlice(self.content);

        const message = try message_builder.toOwnedSlice();
        return message;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    _ = try file_init.notes_txt_init();
    var note_list = std.ArrayList(Notes).init(allocator);

    defer note_list.deinit();

    try banner.run_banner();
    try handle_input.handle_input(allocator, &note_list);
}
