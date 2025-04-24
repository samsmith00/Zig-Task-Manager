const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn notes_txt_init() !std.fs.File {
    const cwd = std.fs.cwd();

    return cwd.openFile("notes.txt", .{ .mode = .read_write }) catch |err| switch (err) {
        error.FileNotFound => {
            const file = try cwd.createFile("notes.txt", .{ .read = true, .truncate = true });
            return file;
        },
        else => return err,
    };
}
