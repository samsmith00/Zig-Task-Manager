// This file handles the creation of the notes text file, which will store and display the notes

const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn notes_txt_init() !std.fs.File {
    // getting our current path
    const cwd = std.fs.cwd();

    // if there is already a file created we open the current one, else we create a new file
    return cwd.openFile("notes.txt", .{ .mode = .read_write }) catch |err| switch (err) {
        error.FileNotFound => {
            const file = try cwd.createFile("notes.txt", .{ .read = true, .truncate = true });
            return file;
        },
        else => return err,
    };
}
