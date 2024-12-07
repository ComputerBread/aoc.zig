const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

pub fn part1(this: *const @This()) !?i64 {
    var lines = mem.tokenizeScalar(u8, this.input, '\n');
    var res: i64 = 0;
    while (lines.next()) |line| {
        var it = mem.tokenizeSequence(u8, line, ": ");
        const target = try std.fmt.parseInt(i64, it.next().?, 10);
        const operands = it.next().?;
        var opIt = mem.tokenizeScalar(u8, operands, ' ');
        const first = try std.fmt.parseInt(i64, opIt.next().?, 10);
        if (try check(target, first, opIt)) {
            res += target;
        }
    }
    return res;
}

fn check(target: i64, curr: i64, opIt: mem.TokenIterator(u8, .scalar)) !bool {
    var it = opIt;
    const op = it.next();
    if (curr == target and op == null) {
        return true;
    }
    if (curr > target) return false;
    if (op == null) return false;
    const opVal = try std.fmt.parseInt(i64, op.?, 10);
    return try check(target, curr + opVal, it) or try check(target, curr * opVal, it);
}

pub fn part2(this: *const @This()) !?i64 {
    var lines = mem.tokenizeScalar(u8, this.input, '\n');
    var res: i64 = 0;
    while (lines.next()) |line| {
        var it = mem.tokenizeSequence(u8, line, ": ");
        const target = try std.fmt.parseInt(i64, it.next().?, 10);
        const operands = it.next().?;
        var opIt = mem.tokenizeScalar(u8, operands, ' ');
        const first = try std.fmt.parseInt(i64, opIt.next().?, 10);
        if (try check2(target, first, opIt)) {
            res += target;
        }
    }
    return res;
}

fn check2(target: i64, curr: i64, opIt: mem.TokenIterator(u8, .scalar)) !bool {
    var it = opIt;
    const op = it.next();
    if (curr == target and op == null) {
        return true;
    }
    if (curr > target) return false;
    if (op == null) return false;
    const opVal = try std.fmt.parseInt(i64, op.?, 10);
    return try check2(target, curr + opVal, it) or try check2(target, curr * opVal, it) or try check2(target, curr * std.math.pow(i64, 10, @intCast(op.?.len)) + opVal, it);
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
