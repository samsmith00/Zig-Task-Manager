const std = @import("std");
const banner = @import("banner.zig");
const handle_input = @import("input.zig");
const file_init = @import("initialize_txt_file.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var file = try file_init.notes_txt_init();

    defer file.close();

    try banner.run_banner();
    try handle_input.handle_input(allocator, file);
}
