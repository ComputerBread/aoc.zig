const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

pub fn part1(this: *const @This()) !?i64 {
    var c1 = std.ArrayList(i32).init(this.allocator);
    defer c1.deinit();
    var c2 = std.ArrayList(i32).init(this.allocator);
    defer c2.deinit();

    var it = mem.tokenizeAny(u8, this.input, " \n");
    while (it.next()) |val| {
        const n = try std.fmt.parseUnsigned(i32, val, 10);
        const m = try std.fmt.parseUnsigned(i32, it.next().?, 10);
        try c1.append(n);
        try c2.append(m);
    }

    const c11 = try c1.toOwnedSlice();
    mem.sort(i32, c11, {}, comptime std.sort.asc(i32));
    //mem.sort(u32, &c1, comptime std.sort.asc(u32));
    const c22 = try c2.toOwnedSlice();
    mem.sort(i32, c22, {}, comptime std.sort.asc(i32));
    //std.debug.print("c1 {d}, c2 {d}", .{ mem.len(c11), mem.len(c22) });

    var dist: i64 = 0;

    for (c11, c22) |l, r| {
        dist += @as(i64, @abs(l - r));
    }

    return dist;
}

pub fn part2(this: *const @This()) !?i64 {
    var left = std.ArrayList(i64).init(this.allocator);
    defer left.deinit();

    var right = std.AutoHashMap(i64, i64).init(this.allocator);
    defer right.deinit();

    var it = mem.tokenizeAny(u8, this.input, " \n");
    while (it.next()) |val| {
        const l = try std.fmt.parseUnsigned(i32, val, 10);
        const r = try std.fmt.parseUnsigned(i32, it.next().?, 10);
        try left.append(l);
        const rval = (right.get(r) orelse 0) + 1;
        try right.put(r, rval);
    }
    var res: i64 = 0;
    for (left.items) |lval| {
        res += lval * (right.get(lval) orelse 0);
    }
    return res;
}

test "it should do nothing" {
    const allocator = std.testing.allocator;
    const input = "";

    const problem: @This() = .{
        .input = input,
        .allocator = allocator,
    };

    try std.testing.expectEqual(null, try problem.part1());
    try std.testing.expectEqual(null, try problem.part2());
}
