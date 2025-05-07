/// Files Main Purpose: diplays the name of the program in ASCII text
/// Display the various commands the program can handel
const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn run_banner(allocator: std.mem.Allocator) !void {

    //This is running a command in the terminal, the command is stored in .argv and the result of the process is stored in result.
    // For this case the ascii text is stored in result
    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "figlet", "-f", "ntgreek", "NoteZ" }, // big, ntgreek, speed, starwars
    });

    defer allocator.free(result.stdout);

    // Getting ansi color codes to make the ASCII art colord
    const ansi_blue = "\x1B[34m";
    const ansi_reset_blue = "\x1B[0m";
    const ansi_deep_orange = "\x1B[38;5;208m";
    const ansi_reset_orange = "\x1B[0m";
    try stdout.print("{s}{s}{s}", .{ ansi_deep_orange, result.stdout, ansi_reset_orange });

    // Printing out the commands the program supports
    const commands = "CMDS: * (add) | -done | -del | -clear | -show | -p | -x | \n";
    try std.io.getStdOut().writer().print("{s}{s}{s}", .{ ansi_blue, commands, ansi_reset_blue });
    std.debug.print("\n", .{});
}
