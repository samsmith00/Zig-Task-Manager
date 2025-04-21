const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn notes_txt_init() !std.fs.File {
    const cwd = std.fs.cwd();
    var file =  cwd.openFile("notes.txt", .{
        .mode = .read_write,
    }) catch |err| {
        if (err == error.FileNotFound) {
            return cwd.createFile("notes.txt", .{ .read = true, });
        } else {
            return err;
        }
    };

    const file_size = try file.getEndPos();
    try stdout.print("{d}", .{file_size});
    if (file_size == 0) {
        var i: usize = 0;
        while (i < 30) {
            try file.writeAll("-");
            i += 1;
        }
    }

    return file;
}
