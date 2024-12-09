const std = @import("std");
const fs = std.fs;
const io = std.io;
const heap = std.heap;

const Problem = @import("problem");

fn timeit(problem: Problem, part: u8) !?i64 {
    const curtime = std.time.microTimestamp();
    const res = if (part == 1) try problem.part1() else try problem.part2();
    const done = std.time.microTimestamp();
    const us: f64 = @floatFromInt(done - curtime);
    const ms: f64 = us / 1000.0;
    std.debug.print("({d:.3} ms) part {d}: ", .{ ms, part });
    return res;
}
pub fn main() !void {
    const stdout = io.getStdOut().writer();

    var arena = heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const problem = Problem{
        .input = @embedFile("input"),
        .allocator = allocator,
    };

    if (try timeit(problem, 1)) |solution|
        try stdout.print(switch (@TypeOf(solution)) {
            []const u8 => "{s}",
            else => "{any}",
        } ++ "\n", .{solution});

    if (try timeit(problem, 2)) |solution|
        try stdout.print(switch (@TypeOf(solution)) {
            []const u8 => "{s}",
            else => "{any}",
        } ++ "\n", .{solution});
}
