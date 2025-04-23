const std = @import("std");
const parse_input = @import("parse_input.zig");
const arg_set_path = @import("arg_set.zig");
const file_init = @import("initialize_txt_file.zig");
const Notes = @import("main.zig").Notes;
const stdout = std.io.getStdOut().writer();

// MAYBE WANT TO MAKE NOTE LIST IN MAIN FUNC AND PASS TO HERE
// THEN YOU CAN DEALLOCATE NOTE LIST IN MAIN, THIS WAY NOT DEALLOCATING TOO EARLY

/// WHAT TO WROK ON
/// Make a note struct that has a note id and content
/// hace a dynamic array that holds all of the notes this will be easy to delete and add to
/// Need to make numbers reset when cleared, and right now black returns are considered notes, need to fix that
pub fn handle_input(allocator: std.mem.Allocator, note_list: *std.ArrayList(Notes)) !void {
    const stdin = std.io.getStdIn().reader();
    var note_count: u32 = 1;

    var arg_set = try arg_set_path.set(allocator);
    defer arg_set.deinit();

    outer: while (true) {
        const input_buff = try stdin.readUntilDelimiterAlloc(allocator, '\n', 512);
        defer allocator.free(input_buff);

        const args = try parse_input.parse_input(allocator, input_buff);
        defer args.deinit();

        const content = try remove_args(allocator, input_buff, arg_set);

        if (content.len > 0 or args.items.len > 0) {
            if (content.len > 0) {
                const new_note = Notes.init(note_count, content, allocator);
                _ = try note_list.append(new_note);
                //try display_notes(note_list);
            }

            note_count += 1;
            for (args.items) |arg| {
                //try stdout.print("{s}", .{arg});
                if (std.mem.eql(u8, arg, "-done")) {
                    break :outer;
                } else if (std.mem.eql(u8, arg, "-show")) {
                    try write_to_file(note_list);
                    const file = try std.fs.cwd().openFile("notes.txt", .{ .mode = .read_only });
                    defer file.close();
                    try display_file(file, allocator);
                } else if (std.mem.eql(u8, arg, "-clear")) {
                    try std.fs.cwd().deleteFile("notes.txt");
                    note_list.clearRetainingCapacity();
                    note_count = 0;
                    //try stdout.print("{s}", .{"Deleated notes"});
                }
            }
        }
    }
}

// will be used right before note is added to the note_list, NEEDO TO APPEND NEW LINE TO END OF EACH NOTE GOING INTO THE CONTENT
fn remove_args(allocator: std.mem.Allocator, input: []const u8, arg_set: std.BufSet) ![]const u8 {
    const note_copy = try allocator.dupe(u8, input);
    var split_iter = std.mem.tokenizeScalar(u8, note_copy, ' ');

    var buff = std.ArrayList(u8).init(allocator);

    while (split_iter.next()) |word| {
        if (!arg_set.contains(word)) {
            try buff.appendSlice(word);
            try buff.append(' ');
        }
    }
    //try stdout.print("Length: {d}\n", .{buff.items.len});
    if (buff.items.len > 0) {
        _ = buff.pop();
        try buff.append('\n');
    }

    const string_to_add = try buff.toOwnedSlice();

    return string_to_add;
}

fn display_file(file: std.fs.File, allocator: std.mem.Allocator) !void {
    const file_size = try file.getEndPos();

    const bytes_read = try allocator.alloc(u8, file_size);
    defer allocator.free(bytes_read);

    try file.seekTo(0);
    _ = try file.readAll(bytes_read);
    try stdout.print("{s}", .{bytes_read});
}

fn display_notes(input: *std.ArrayList(Notes)) !void {
    for (input.items) |note| {
        try note._display();
    }
}

fn write_to_file(note_list: *std.ArrayList(Notes)) !void {
    var file = try file_init.notes_txt_init();
    defer file.close();

    for (note_list.items) |note| {
        const str = try note._format_for_file();
        try file.writeAll(str);
        defer note.allocator.free(str);
    }
}
