const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Type = union(enum) {
    empty,
    visited,
    blocked,
    bounced: u8,
};
const Dir = enum {
    UP,
    RIGHT,
    DOWN,
    LEFT,

    fn rotate(self: Dir) Dir {
        return switch (self) {
            .UP => .RIGHT,
            .RIGHT => .DOWN,
            .DOWN => .LEFT,
            .LEFT => .UP,
        };
    }

    fn toBit(self: Dir) u8 {
        return switch (self) {
            .UP => 0b1,
            .RIGHT => 0b10,
            .DOWN => 0b100,
            .LEFT => 0b1000,
        };
    }
};
pub fn part1(this: *const @This()) !?i64 {
    var grid = [_][130]Type{[_]Type{.empty} ** 130} ** 130;
    var r: usize = 0;
    var c: usize = 0;
    var it = mem.tokenizeScalar(u8, this.input, '\n');
    var i: usize = 0;
    var dir = Dir.UP;
    while (it.next()) |row| : (i += 1) {
        for (row, 0..) |cell, j| {
            if (cell == '#') {
                grid[i][j] = .blocked;
            } else if (cell == '^') {
                grid[i][j] = .visited;
                r = i;
                c = j;
            }
        }
    }
    var res: i64 = 1;
    while (moveForward(&r, &c, dir)) {
        if (grid[r][c] == .empty) {
            res += 1;
            grid[r][c] = .visited;
        } else if (grid[r][c] == .blocked) {
            moveBackward(&r, &c, dir);
            dir = dir.rotate();
        }
    }

    return res;
}

fn moveForward(r: *usize, c: *usize, dir: Dir) bool {
    switch (dir) {
        .UP => {
            if (r.* == 0) return false;
            r.* -= 1;
        },
        .RIGHT => {
            if (c.* == 129) return false;
            c.* += 1;
        },
        .DOWN => {
            if (r.* == 129) return false;
            r.* += 1;
        },
        .LEFT => {
            if (c.* == 0) return false;
            c.* -= 1;
        },
    }
    return true;
}

fn moveBackward(r: *usize, c: *usize, dir: Dir) void {
    switch (dir) {
        .UP => {
            r.* += 1;
        },
        .RIGHT => {
            c.* -= 1;
        },
        .DOWN => {
            r.* -= 1;
        },
        .LEFT => {
            c.* += 1;
        },
    }
}

// if you hit the same side of a block twice you should be in loop right?
pub fn part2(this: *const @This()) !?i64 {
    var grid = [_][130]Type{[_]Type{.empty} ** 130} ** 130;
    var r: usize = 0;
    var c: usize = 0;

    var it = mem.tokenizeScalar(u8, this.input, '\n');
    var i: usize = 0;
    var dir = Dir.UP;

    while (it.next()) |row| : (i += 1) {
        for (row, 0..) |cell, j| {
            if (cell == '#') {
                grid[i][j] = .blocked;
            } else if (cell == '^') {
                grid[i][j] = .visited;
                r = i;
                c = j;
            }
        }
    }

    var res: i64 = 0;
    while (moveForward(&r, &c, dir)) {
        if (grid[r][c] == .empty) {
            grid[r][c] = .blocked;
            moveBackward(&r, &c, dir);
            if (isLooping(r, c, dir, grid)) {
                res += 1;
            }
            _ = moveForward(&r, &c, dir);
            grid[r][c] = .visited;
        } else if (grid[r][c] == .blocked) {
            moveBackward(&r, &c, dir);
            dir = dir.rotate();
        }
    }
    return res;
}

fn isLooping(rr: usize, cc: usize, dir: Dir, g: [130][130]Type) bool {
    var r = rr;
    var c = cc;
    var d = dir;
    var grid = g;
    while (moveForward(&r, &c, d)) {
        switch (grid[r][c]) {
            .bounced => |*val| {
                if (val.* & d.toBit() != 0) {
                    return true;
                }
                val.* |= d.toBit();
                moveBackward(&r, &c, d);
                d = d.rotate();
            },
            .blocked => {
                grid[r][c] = .{ .bounced = d.toBit() };
                moveBackward(&r, &c, d);
                d = d.rotate();
            },
            else => {},
        }
    }
    return false;
}

fn printGrid(g: [130][130]Type, rr: usize, cc: usize) void {
    std.debug.print("bitch what? {} {}\n", .{ rr, cc });
    for (0..10) |r| {
        for (0..10) |c| {
            if (r == rr and c == cc) {
                std.debug.print("O", .{});
                continue;
            }
            const p: u8 = switch (g[r][c]) {
                .empty => '.',
                .blocked => '#',
                .visited => '^',
                .bounced => '+',
            };
            std.debug.print("{c}", .{p});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}
