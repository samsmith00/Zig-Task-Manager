const std = @import("std"); 
const Notes = @import("main.zig").Notes;



pub fn save_notes_as_json(list: *std.ArrayList(Notes), allocator: std.mem.Allocator) !void {

    var file = create_json_file() catch |err| switch
    (err) {
        error.FileNotFound => return,
        else => return err
    };

    defer file.close();
    

    const jsonStruct = struct 
    {
        id: u32,
        str_id: []const u8,
        content: []const u8,
        status: bool,
    };

    var jsonArray = std.ArrayList(u8).init(allocator);
    defer jsonArray.deinit();

    try jsonArray.append('[');
    try jsonArray.append('\n');
    try jsonArray.append('\t');
    
    for (list.items, 0..) |note, i| {
        if (i != 0) {
            try jsonArray.append(',');
            try jsonArray.append('\n');
            try jsonArray.append('\t');
        }

        const struct_to_insert = jsonStruct {
            .id = note.id,
            .str_id = note.str_id,
            .content = note.content,
            .status = note.status
        };

        try std.json.stringify(struct_to_insert, .{}, jsonArray.writer());
    }
    
    try jsonArray.append('\n');
    try jsonArray.append(']');

    try file.writeAll(jsonArray.items);
}

//------------------------------------ Helper Functions ------------------------------------


fn create_json_file() !std.fs.File {
    const cwd = std.fs.cwd();
    return cwd.createFile("notes.json", .{.truncate = true });
}

pub fn does_exist() !bool {
    _ = std.fs.cwd().openFile("notes.json", .{}) catch |err|
    switch (err) {
        error.FileNotFound => return false, 
        else => return err
    };
    return true;
}

//------------------------------------------------------------------------------------------



pub fn read_json_notes(note_list: *std.ArrayList(Notes), allocator: std.mem.Allocator, note_count: *u32) !void {
    const cwd = std.fs.cwd();
    const json_file = try cwd.openFile("notes.json", .{ .mode = .read_only });
    defer json_file.close();

    const file_size = try json_file.getEndPos();
    try json_file.seekTo(0);

    const buff = try allocator.alloc(u8, file_size);
    defer allocator.free(buff);

    _ = try json_file.readAll(buff);
    
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, buff, .{ .allocate = .alloc_always });
    defer parsed.deinit();

    var highest_id: u32 = 1;

    for (parsed.value.array.items) |item| {

        const id_temp = item.object.get("id").?.integer;
        const id = std.math.cast(u32, id_temp) orelse return error.IdOutOfRange;
        //const str_id = item.object.get("str_id").?.string;
        const content = item.object.get("content").?.string;
        const status = item.object.get("status").?.bool;

        const new_note = try Notes.init( id, content, allocator, status);


        try note_list.append(new_note);

        if (id > highest_id) {
            highest_id = id;
        }
    }

    note_count.* = highest_id + 1;
}   