const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

// bro I change nothing and it works now
pub fn part1(this: *const @This()) !?i64 {
    var safe: i64 = 0;
    var unsafe: i64 = 0;

    var lines = mem.splitScalar(u8, this.input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var lvl = mem.splitScalar(u8, line, ' ');
        var prev = try std.fmt.parseInt(i32, lvl.next().?, 10);
        const sec = try std.fmt.parseInt(i32, lvl.next().?, 10);

        const inc = prev < sec;
        var diff = if (inc) sec - prev else prev - sec;
        var isSafe = diff > 0 and diff < 4;
        if (!isSafe) {
            continue;
        }
        prev = sec;
        while (lvl.next()) |currr| {
            const curr = try std.fmt.parseInt(i32, currr, 10);
            if ((inc and curr <= prev) or (!inc and curr >= prev)) {
                isSafe = false;
                break;
            }
            diff = if (inc) curr - prev else prev - curr;
            if (diff <= 0 or diff >= 4) {
                isSafe = false;
                break;
            }
            prev = curr;
        }
        if (isSafe) {
            safe += 1;
        } else unsafe += 1;
    }
    return safe;
}

pub fn part2(this: *const @This()) !?i64 {
    var safe: i64 = 0;

    var lines = mem.splitScalar(u8, this.input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var lvl = mem.splitScalar(u8, line, ' ');
        var prev = try std.fmt.parseInt(i32, lvl.next().?, 10);
        var inc = 0;
        var dec = 0;
        var error_count = 0;
        while (lvl.next()) |currr| {
            const curr = try std.fmt.parseInt(i32, currr, 10);
            if (prev < curr) {
                inc += 1;
            } else if (prev > curr) {
                dec += 1;
            } else { // if curr == prev
                error_count += 1;
                continue;
            }
            const diff = @abs(curr - prev);
            if (diff > 3)
        }
    }
    return null;
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
