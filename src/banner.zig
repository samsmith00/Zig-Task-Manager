const std = @import("std");

pub fn run_banner() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "figlet", "-f", "big", "NoteZ" },
    });

    defer allocator.free(result.stdout);

    try std.io.getStdOut().writeAll(result.stdout);

    try std.io.getStdOut().writer().writeAll("CMDS: * (add) | -done | -del | -clear | -show | -p \n");
    std.debug.print("\n", .{});
}
