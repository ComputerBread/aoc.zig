const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

pub fn part1(this: *const @This()) !?i64 {
    const len = this.input.len;
    var res: i64 = 0;
    var i: usize = 0;
    while ((i + 4) < len) { // revoir condition
        if (!mem.eql(u8, "mul(", this.input[i .. i + 4])) {
            i += 1;
            continue;
        }
        i += 4;
        // first number
        const left = i;
        while ('0' <= this.input[i] and this.input[i] <= '9') {
            i += 1;
        }
        if (left == i or ',' != this.input[i]) {
            continue;
        }
        const l = try std.fmt.parseInt(i64, this.input[left..i], 10);

        i += 1; // ','

        const right = i;
        while ('0' <= this.input[i] and this.input[i] <= '9') {
            i += 1;
        }
        if (right == i or ')' != this.input[i]) {
            continue;
        }
        const r = try std.fmt.parseInt(i64, this.input[right..i], 10);
        res += l * r;

        i += 1;
    }

    return res;
}

pub fn part2(this: *const @This()) !?i64 {
    const len = this.input.len;
    var res: i64 = 0;
    var i: usize = 0;
    var enabled = true;
    while ((i + 4) < len) { // revoir condition
        if (!enabled) {
            if (!mem.eql(u8, "do()", this.input[i .. i + 4])) {
                i += 1;
                continue;
            }
            enabled = true;
            i += 4;
        }
        if (mem.eql(u8, "don't()", this.input[i .. i + 7])) {
            enabled = false;
            i += 7;
            continue;
        }
        if (!mem.eql(u8, "mul(", this.input[i .. i + 4])) {
            i += 1;
            continue;
        }
        i += 4;
        // first number
        const left = i;
        while ('0' <= this.input[i] and this.input[i] <= '9') {
            i += 1;
        }
        if (left == i or ',' != this.input[i]) {
            continue;
        }
        const l = try std.fmt.parseInt(i64, this.input[left..i], 10);

        i += 1; // ','

        const right = i;
        while ('0' <= this.input[i] and this.input[i] <= '9') {
            i += 1;
        }
        if (right == i or ')' != this.input[i]) {
            continue;
        }
        const r = try std.fmt.parseInt(i64, this.input[right..i], 10);
        //std.debug.print("mul({d},{d})\n", .{ l, r });
        res += l * r;

        i += 1;
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
