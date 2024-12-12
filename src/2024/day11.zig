const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

fn nbDigits(n: u64) u64 {
    if (n == 0) return 0;
    return std.math.log10(n) + 1;
}

fn p(map: *std.StringHashMap(u64), n: u64, i: u64, allocator: mem.Allocator) u64 {
    if (i == 0) return 1;

    const key = std.fmt.allocPrint(allocator, "{d}-{d}", .{ n, i }) catch unreachable;
    if (map.contains(key)) {
        return map.get(key).?;
    }
    var res: u64 = 0;
    const nbD = nbDigits(n);
    if (n == 0) {
        res = p(map, 1, i - 1, allocator);
    } else if ((nbD & 1) == 0) {
        const shift = std.math.pow(u64, 10, nbD / 2);
        res = p(map, n / shift, i - 1, allocator) + p(map, n % shift, i - 1, allocator);
    } else {
        res = p(map, n * 2024, i - 1, allocator);
    }
    map.put(key, res) catch unreachable;
    return res;
}

pub fn part1(this: *const @This()) !?i64 {
    // last character is annoying
    var it = mem.tokenizeScalar(u8, this.input[0 .. this.input.len - 1], ' ');
    var map = std.StringHashMap(u64).init(this.allocator);
    defer {
        var mit = map.iterator();
        while (mit.next()) |entry| {
            this.allocator.free(entry.key_ptr.*);
        }
        map.deinit();
    }

    var res: u64 = 0;
    const i: u64 = 25;
    while (it.next()) |n| {
        const num = std.fmt.parseInt(u64, n, 10) catch {
            continue;
        };
        res += p(&map, num, i, this.allocator);
    }
    return @intCast(res);
}

pub fn part2(this: *const @This()) !?i64 {
    // last character is annoying
    var it = mem.tokenizeScalar(u8, this.input[0 .. this.input.len - 1], ' ');
    var map = std.StringHashMap(u64).init(this.allocator);
    defer {
        var mit = map.iterator();
        while (mit.next()) |entry| {
            this.allocator.free(entry.key_ptr.*);
        }
        map.deinit();
    }

    var res: u64 = 0;
    const i: u64 = 75;
    while (it.next()) |n| {
        if (n[0] < '0' or n[0] > '9') continue;
        const num = std.fmt.parseInt(u64, n, 10) catch unreachable;
        res += p(&map, num, i, this.allocator);
    }
    return @intCast(res);
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
