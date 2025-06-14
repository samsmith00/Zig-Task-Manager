/// Reads user input
/// Breaks extracts the keywords (args)
/// Checks which args the user used and preforms various actions based on what args are used
/// Creates note structs and adds them to the note_list, which is a dynamic array that holds the note structs
const std = @import("std");
const parse_input = @import("parse_input.zig");
const arg_set_path = @import("arg_set.zig");
const file_init = @import("initialize_txt_file.zig");
const Notes = @import("main.zig").Notes;
const to_json = @import("save_tasks.zig");
const stdout = std.io.getStdOut().writer();

// MAYBE WANT TO MAKE NOTE LIST IN MAIN FUNC AND PASS TO HERE
// THEN YOU CAN DEALLOCATE NOTE LIST IN MAIN, THIS WAY NOT DEALLOCATING TOO EARLY

/// WHAT TO WROK ON
/// Make a note struct that has a note id and content
/// hace a dynamic array that holds all of the notes this will be easy to delete and add to
/// Need to make numbers reset when cleared, and right now black returns are considered notes, need to fix that
pub fn handle_input(allocator: std.mem.Allocator, note_list: *std.ArrayList(Notes), note_count: *u32) !void {
    const stdin = std.io.getStdIn().reader();

    var arg_set = try arg_set_path.set(allocator);
    defer arg_set.deinit();

    // Loop that continuously accepts user input until -done keyword is used. Gave loop a label so we can directly break the loop
    check_args: while (true) {
        // getting the user input
        const input_buff = try stdin.readUntilDelimiterAlloc(allocator, '\n', 512);
        defer allocator.free(input_buff);

        // Getting all the args the user typed
        const args = try parse_input.parse_input(allocator, input_buff);
        defer args.deinit();

        // Getting the exact args that the usere uses
        var args_subset = try arg_set_path.create_subset(allocator, args);
        defer args_subset.deinit();

        // String representation of the user's task
        const content = try remove_args(allocator, input_buff, arg_set);

        if (content.len > 0 or args.items.len > 0) {

            // NOTE clean up loop, make everything into their own functions
            // Loop to preform various actions based on the args
            // have to rework this because now file is being passed from main func
            for (args.items) |arg| {
                
                if (std.mem.eql(u8, arg, "-s"))
                {
                    try write_and_show_container(note_list, allocator, false);
                }
                else if (std.mem.eql(u8, arg, "-show")) 
                {   
                    //try display_notes(note_list); => for debugging
                    try write_and_show_container(note_list, allocator, true);
                } 
                else if (std.mem.eql(u8, arg, "-clear")) 
                {
                    try std.fs.cwd().deleteFile("notes.txt");
                    
                    const json_file_exists = try to_json.does_exist();
                    if (json_file_exists)
                    {
                        try std.fs.cwd().deleteFile("notes.json");
                    }
                    note_list.clearAndFree();
                    note_count.* = 1;
                    //try stdout.print("{s}", .{"Deleated notes"});
                } 
                else if (std.mem.eql(u8, arg, "-x")) 
                {
                    var target = content;
                    target = std.mem.trimRight(u8, target, "\n\r");
                    _ = try mark_task_as_done(note_list, target);
                } 
                else if (std.mem.eql(u8, arg, "-del")) 
                {
                    var target = content;
                    target = std.mem.trimRight(u8, target, "\n\r");
                    try delet_specific_task(note_list, target);
                    try write_to_file(note_list, 'Y');
                }
                else if (std.mem.eql(u8, arg, "-done")) 
                {
                    //try write_and_show_container(note_list, allocator);
                    if (note_list.items.len != 0) {
                        try to_json.save_notes_as_json(note_list, allocator);
                    }
                    break :check_args;
                }
            }
            // Making sure we do not add content to notes if it pertains to deleting or checking off notes
            const is_removed = if (args_subset.contains("-x") or args_subset.contains("-del")) true else false;
            if (content.len > 0 and !is_removed) {
                const id = note_count.*;
                const new_note = try Notes.init(id, content, allocator, false);
                _ = try note_list.append(new_note);
                note_count.* += 1;
                //try display_notes(note_list);



                //  const new_note = try allocator.create(Notes);
                // const str_id = try std.fmt.allocPrint(allocator, "{d}", .{note_count});
                // new_note.* = Notes {
                //     .id = note_count,
                //     .str_id = str_id,
                //     .content = content,
                //     .allocator = allocator, 
                //     .status = false
                // };
            }
        }
    }
}
// This function removes the args from the user input, this way we just add the task to the note_list
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
    if (buff.items.len > 0) {
        _ = buff.pop();
        try buff.append('\n');
    }

    const string_to_add = try buff.toOwnedSlice();

    return string_to_add;
}

fn write_and_show_container(note_list: *std.ArrayList(Notes), allocator: std.mem.Allocator, flag: bool) !void {
    try write_to_file(note_list, 'Y');

    if (flag) {
       try only_show_file(allocator);
    }
}

// Function to display the file
fn display_file(file: std.fs.File, allocator: std.mem.Allocator) !void {
    const file_size = try file.getEndPos();

    const bytes_read = try allocator.alloc(u8, file_size);
    defer allocator.free(bytes_read);

    try file.seekTo(0);
    const count = try file.readAll(bytes_read);
    try stdout.writeAll(bytes_read[0..count]);
}

// NOTE Debug function, used to see what tasks are in notes_list
fn display_notes(input: *std.ArrayList(Notes)) !void {
    for (input.items) |note| {
        try note._display();
    }
}

// Function to write the notes stored in note_list to a text file.
fn write_to_file(note_list: *std.ArrayList(Notes), should_truncate: u8) !void {
    if (should_truncate == 'Y') {
        var file = try std.fs.cwd().createFile("notes.txt", .{ .truncate = true });
        defer file.close();
        for (note_list.items) |note| {
            const str = try note._format_for_file();
            try file.writeAll(str);
            defer note.allocator.free(str);
        }
        return;
    }

    var file = try file_init.notes_txt_init();
    defer file.close();

    const file_size = try file.getEndPos();
    try file.seekTo(file_size);
    for (note_list.items) |note| {
        const str = try note._format_for_file();
        try file.writeAll(str);
        defer note.allocator.free(str);
    }
}
// Prints the orange divider that marks the start of the notes
fn print_divider() !void {
    var i: usize = 0;
    while (i < 40) {
        if (i % 2 == 0) {
            try stdout.print("\x1b[38;5;208m/\x1b[0m", .{});
        } else {
            try stdout.print("\x1b[38;5;208m\\\x1b[0m", .{});
        }
        i += 1;
    }
    try stdout.print("\n", .{});
}

// Checks off the  that the user has marked as done
fn mark_task_as_done(input: *std.ArrayList(Notes), target: []const u8) !void {
    for (input.items) |*note| {
        if (std.mem.eql(u8, target, note.str_id)) {
            note.change_status(true);
            // for debugging
            //try note._display();
        }
    }
    try write_to_file(input, 'Y');
}

// Delete spicific taks in note_list
fn delet_specific_task(input: *std.ArrayList(Notes), target: []const u8) !void {
    var i: usize = input.items.len;
    while (i > 0) {
        i -= 1;
        if (std.mem.eql(u8, input.items[i].str_id, target)) {
            _ = input.orderedRemove(i);
        }
    }
}

pub fn only_show_file(allocator: std.mem.Allocator) !void {
    const show_file = try std.fs.cwd().openFile("notes.txt", .{ .mode = .read_only });
    defer show_file.close();
    try print_divider();
    try display_file(show_file, allocator);
}
