const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn run_banner() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "figlet", "-f", "ntgreek", "NoteZ" }, // big, ntgreek, speed, starwars
    });

    defer allocator.free(result.stdout);

    const ansi_blue = "\x1B[34m";
    const ansi_reset_blue = "\x1B[0m";
    const ansi_deep_orange = "\x1B[38;5;208m";
    const ansi_reset_orange = "\x1B[0m";
    try stdout.print("{s}{s}{s}", .{ansi_deep_orange, result.stdout, ansi_reset_orange});

    const commands = "CMDS: * (add) | -done | -del | -clear | -show | -p \n";
    try std.io.getStdOut().writer().print("{s}{s}{s}", .{ansi_blue, commands, ansi_reset_blue});
    std.debug.print("\n", .{});
}
