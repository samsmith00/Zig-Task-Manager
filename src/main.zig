const std = @import("std");
const banner = @import("banner.zig");
const handle_input = @import("input.zig");
const file_init = @import("initialize_txt_file.zig");

const stdout = std.io.getStdOut().writer();

/// Tasks to complete (for myself)
///     1. make delete notes function ✅
///     -----------------------------------------------------------------
///    | 1.5 Fix note file, right now notes go away after function closes |✅
///     -----------------------------------------------------------------
///     2. make priority (some how to write to top of file)
///             - Loop through note list, if note less than target, continue if == target remove, if greater than target subtract 1 from id, update id_str
///     3. check off individual tasks ✅


// Notes Struct
pub const Notes = struct {
    id: u32,
    str_id: []const u8,
    content: []const u8,
    allocator: std.mem.Allocator,
    status: bool,

    // Initialize all note stucts
    pub fn init(num: u32, str: []const u8, allocator: std.mem.Allocator, is_complete: bool) !Notes {
        const str_id = try std.fmt.allocPrint(allocator, "{d}", .{num});
        return Notes{ 
            .id = num, 
            .str_id = str_id, 
            .content = str, 
            .allocator = allocator, 
            .status = is_complete 
        };
    }
    // For debugging
    pub fn _display(self: Notes) !void {
        try stdout.print("{d}. ", .{self.id});
        try stdout.print("{s} ", .{self.content});
        try stdout.print("{s} \n", .{if (self.status) "true" else "false"});
        try stdout.print("-------------------------------\n", .{});
    } 
    // used before adding notes to the file to dispaly and save
    pub fn _format_for_file(self: Notes) ![]u8 {
        //const id_as_str = try std.fmt.allocPrint(self.allocator, "{d}", .{self.id});
        var message_builder = std.ArrayList(u8).init(self.allocator);
        defer message_builder.deinit();

        const status = if (self.status) "[X] " else "[ ] ";
        try message_builder.appendSlice(self.str_id);
        try message_builder.appendSlice(". ");
        try message_builder.appendSlice(status);
        try message_builder.appendSlice(" ");
        try message_builder.appendSlice(self.content);

        const message = try message_builder.toOwnedSlice();
        return message;
    }
    // Used to change the status for a particular note. Allows for notes to be checked off
    pub fn change_status(self: *Notes, status: bool) void {
        self.status = status;
    }
};

pub fn main() !void {
    // Creating an allocator object I can pass around my program
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    _ = try file_init.notes_txt_init();
    var note_list = std.ArrayList(Notes).init(allocator);

    defer note_list.deinit();

    try banner.run_banner(allocator);
    // This is the entry point to the main functionalities to the program
    try handle_input.handle_input(allocator, &note_list);
}
