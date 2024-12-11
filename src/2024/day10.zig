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

// const in =
//     \\89010123
//     \\78121874
//     \\87430965
//     \\96549874
//     \\45678903
//     \\32019012
//     \\01329801
//     \\10456732
// ;

const SIZE = 54; // TODO: TO CHANGE
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
    //std.debug.print("sub {}, overflow {}\n", .{ sub[0], sub[1] });
    if (sub[1] == 1 or sub[0] != 1) return null;
    //std.debug.print("({}, {}), ({}, {})\n", .{ next, grid[next[0]][next[1]], curr, grid[curr[0]][curr[1]] });
    return next;
}

pub fn part1(this: *const @This()) !?i64 {
    const in = this.input;
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
        res += try this.computeScore(nodes.pop());
    }

    return @intCast(res);
}

fn append(nodes: *std.ArrayList(@Vector(2, usize)), node: @Vector(2, usize), dir: Dir, visited: *std.AutoHashMap(@Vector(2, usize), bool)) !usize {
    const n = moveForward(node, dir);
    if (n == null) {
        return 0;
    }
    const v = n.?;
    if (grid[v[0]][v[1]] == 9) {
        if (visited.contains(v)) return 0;
        try visited.put(v, true);
        return 1;
    }
    try nodes.append(v);
    return 0;
}

fn computeScore(this: *const @This(), node: @Vector(2, usize)) !usize {
    var nodes = std.ArrayList(@Vector(2, usize)).init(this.allocator);
    defer nodes.deinit();
    try nodes.append(node);

    var visited = std.AutoHashMap(@Vector(2, usize), bool).init(this.allocator);
    defer visited.deinit();

    var res: usize = 0;
    while (nodes.items.len != 0) {
        const n = nodes.pop();
        res += try append(&nodes, n, .UP, &visited);
        res += try append(&nodes, n, .DOWN, &visited);
        res += try append(&nodes, n, .LEFT, &visited);
        res += try append(&nodes, n, .RIGHT, &visited);
    }
    return res;
}

pub fn part2(this: *const @This()) !?i64 {
    const in = this.input;
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
        const n = nodes.pop();
        res += try append2(&nodes, n, .UP);
        res += try append2(&nodes, n, .DOWN);
        res += try append2(&nodes, n, .LEFT);
        res += try append2(&nodes, n, .RIGHT);
    }

    return @intCast(res);
}
fn append2(nodes: *std.ArrayList(@Vector(2, usize)), node: @Vector(2, usize), dir: Dir) !usize {
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
