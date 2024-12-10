const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Dir = enum {
    UP,
    RIGHT,
    DOWN,
    LEFT,
};

const in =
    \\89010123
    \\78121874
    \\87430965
    \\96549874
    \\45678903
    \\32019012
    \\01329801
    \\10456732
;

const SIZE = 8; // TODO: TO CHANGE
var grid = [_][SIZE]u8{[_]u8{0} ** SIZE} ** SIZE;

fn moveForward(curr: @Vector(2, usize), dir: Dir) ?@Vector(2, usize) {
    var next: @Vector(2, usize) = undefined;
    switch (dir) {
        .UP => {
            if (curr[0] == 0) return null;
            next = @Vector(2, usize){ curr[0] - 1, curr[1] };
        },
        .RIGHT => {
            if (curr[1] == SIZE - 1) return null;
            next = @Vector(2, usize){ curr[0], curr[1] + 1 };
        },
        .DOWN => {
            if (curr[0] == SIZE - 1) return null;
            next = @Vector(2, usize){ curr[0] + 1, curr[1] };
        },
        .LEFT => {
            if (curr[1] == 0) return null;
            next = @Vector(2, usize){ curr[0], curr[1] - 1 };
        },
    }
    const sub = @subWithOverflow(grid[next[0]][next[1]], grid[curr[0]][curr[1]]);
    std.debug.print("sub {}, overflow {}\n", .{ sub[0], sub[1] });
    if (sub[1] == 1 or sub[0] != 1) return null;
    std.debug.print("({}, {}), ({}, {})\n", .{ next, grid[next[0]][next[1]], curr, grid[curr[0]][curr[1]] });
    return next;
}

pub fn part1(this: *const @This()) !?i64 {
    var nodes = std.ArrayList(@Vector(2, usize)).init(this.allocator);
    defer nodes.deinit();

    var lines = mem.tokenizeScalar(u8, in, '\n');
    var r: usize = 0;
    while (lines.next()) |line| : (r += 1) {
        for (0..line.len) |c| {
            if (line[c] < '0' or line[c] > '9') {
                continue;
            }
            const val: u8 = line[c] - '0';
            grid[r][c] = val;
            if (val == 0) {
                try nodes.append(.{ r, c });
            }
        }
    }

    var res: usize = 0;
    while (nodes.items.len != 0) {
        const node = nodes.pop();
        //std.debug.print("{} \n", .{node});
        res += try append(&nodes, node, .UP);
        res += try append(&nodes, node, .DOWN);
        res += try append(&nodes, node, .LEFT);
        res += try append(&nodes, node, .RIGHT);
    }

    return @intCast(res);
}

fn append(nodes: *std.ArrayList(@Vector(2, usize)), node: @Vector(2, usize), dir: Dir) !usize {
    const n = moveForward(node, dir);
    if (n == null) {
        return 0;
    }
    const v = n.?;
    if (grid[v[0]][v[1]] == 9) {
        return 1;
    }
    try nodes.append(v);
    return 0;
}

pub fn part2(this: *const @This()) !?i64 {
    _ = this;
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
