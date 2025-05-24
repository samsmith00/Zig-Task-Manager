const std = @import("std");
const banner = @import("banner.zig");
const handle_input = @import("input.zig");
const file_init = @import("initialize_txt_file.zig");
const valid_args = @import("arg_set.zig");
const to_json = @import("save_tasks.zig");
const stdout = std.io.getStdOut().writer();

/// Tasks to complete (for myself)
///     1. make delete notes function ✅
///     -----------------------------------------------------------------
///    | 1.5 Fix note file, right now notes go away after function closes |✅
///     -----------------------------------------------------------------
///     2. make priority (some how to write to top of file)
///             - Loop through note list, if note less than target, continue if == target remove, if greater than target subtract 1 from id, update id_str
///     3. check off individual tasks ✅
/// 
/// NOTE Make program accept command line arguments, able to show without actually running program etc.
/// accept -show, -add, -clear, for single use cases, make program more modular, breakup some more functions ect. 
// Notes Struct
pub const Notes = struct {
    id: u32,
    str_id: []const u8,
    content: []const u8,
    allocator: std.mem.Allocator,
    status: bool,

    // Initialize all note stucts
    pub fn init(id: u32, str: []const u8, allocator: std.mem.Allocator, is_complete: bool) !Notes {
        const str_id = try std.fmt.allocPrint(allocator, "{d}", .{id});
        const content_copy = try allocator.dupe(u8, str);
        return Notes{ 
            .id = id, 
            .str_id = str_id, 
            .content = content_copy, 
            .allocator = allocator, 
            .status = is_complete 
        };
    }
    // For debugging
    pub fn _display(self: Notes) !void {
        try stdout.print("{d}. ",.{self.id});
        try stdout.print("{s} ", .{self.content});
        try stdout.print("{s} \n", .{if (self.status) "true" else "false"});
        try stdout.print("-------------------------------\n", .{});
    }
    // used before adding notes to the file to dispaly and save
    pub fn _format_for_file(self: Notes) ![]u8 {
        //const id_as_str = try std.fmt.allocPrint(self.allocator, "{d}", .{self.id});
        var message_builder = std.ArrayList(u8).init(self.allocator);

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

    pub fn deinit(self: Notes) void{
        self.allocator.free(self.str_id);
        self.allocator.free(self.content);
    }
};

pub fn main() !void {
    // Creating an allocator object I can pass around my program
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    //defer _ = gpa.deinit();

    var note_count: u32 = 1;

    var arg_set = try valid_args.set(allocator);
    defer arg_set.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // std.debug.print("There are {d} args:\n", .{args.len});
    // for(args) |arg| {
    //     std.debug.print("  {s}\n", .{arg});
    // }

    if (args.len > 1)
    {   
         if (std.mem.eql(u8, args[1], "show"))
        {
            try handle_input.only_show_file(allocator);
        }
    }

    _ = try file_init.notes_txt_init();
    var note_list = std.ArrayList(Notes).init(allocator);
    defer note_list.deinit();

    if (args.len < 2)
    {
        try banner.run_banner(allocator);

        const json_file_exists = try to_json.does_exist();

        if (json_file_exists) 
        {
            try to_json.read_json_notes(&note_list, allocator, &note_count);
        }
        // This is the entry point to the main functionalities to the program
        try handle_input.handle_input(allocator, &note_list, &note_count);

        for (note_list.items) |note| {
            note.deinit();
        }
    }


}

// NOTE After doing zig run src/main.zig -- show, when you then go back in and run zig run src/main.zig ✅
// any new note writes over top the current notes. Need to seek to end of file probalby ✅

// NOTE Now the file continuse to write where it was left off. But the numbers are messed up, store note_count
// in file somewhere, read it and set the note_count value to it somehow

