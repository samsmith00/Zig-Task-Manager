const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn notes_txt_init() !std.fs.File {
    const cwd = std.fs.cwd();
    const file = try cwd.createFile("notes.txt", 
    .{.read = true, .truncate = true
    });

    var i: usize = 0;
    while (i < 30) {
        if (i % 2 == 0) {
            try file.writeAll("/");
        }
        else {
            try file.writeAll("\\");
        }
        i += 1;
    }
    try file.writeAll("\n");
    return file;
}


