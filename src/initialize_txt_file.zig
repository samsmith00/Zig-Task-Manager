const std = @import("std");

pub fn notes_txt_init() !std.fs.File {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile("notes.txt", .{
        .read = true,
    }) catch |err| {
        if (err == error.FileNotFound) {
            return cwd.createFile("notes.txt", .{ .read = true });
        } else {
            return err;
        }
    };

    var i: usize = 0;
    while (i < 30) {
        try file.writeAll("-");
        i += 1;
    }

    return file;
}
