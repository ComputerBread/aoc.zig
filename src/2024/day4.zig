const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Dir = enum { U, UL, UR, L, R, D, DL, DR };

fn checkBound(dir: Dir, row: usize, col: usize, len: usize, n_row: usize, n_col: usize) bool {
    switch (dir) {
        .U => return row >= len,
        .UL => return row >= len and col >= len,
        .UR => return row >= len and col + len < n_col,

        .D => return row + len < n_row,
        .DL => return row + len < n_row and col >= len,
        .DR => return row + len < n_row and col + len < n_col,

        .L => return col >= len,
        .R => return col + len < n_col,
    }
}

fn check(dir: Dir, row: usize, col: usize, lvl: usize, word: []const u8, m: std.ArrayList([]const u8)) bool {
    if (lvl == word.len) {
        return true;
    }

    switch (dir) {
        .U => {
            if (word[lvl] != m.items[row - lvl][col]) return false;
            return check(.U, row, col, lvl + 1, word, m);
        },
        .UL => {
            if (word[lvl] != m.items[row - lvl][col - lvl]) return false;
            return check(.UL, row, col, lvl + 1, word, m);
        },
        .UR => {
            if (word[lvl] != m.items[row - lvl][col + lvl]) return false;
            return check(.UR, row, col, lvl + 1, word, m);
        },

        .D => {
            if (word[lvl] != m.items[row + lvl][col]) return false;
            return check(.D, row, col, lvl + 1, word, m);
        },
        .DL => {
            if (word[lvl] != m.items[row + lvl][col - lvl]) return false;
            return check(.DL, row, col, lvl + 1, word, m);
        },
        .DR => {
            if (word[lvl] != m.items[row + lvl][col + lvl]) return false;
            return check(.DR, row, col, lvl + 1, word, m);
        },

        .L => {
            if (word[lvl] != m.items[row][col - lvl]) return false;
            return check(.L, row, col, lvl + 1, word, m);
        },
        .R => {
            if (word[lvl] != m.items[row][col + lvl]) return false;
            return check(.R, row, col, lvl + 1, word, m);
        },
    }
}

pub fn part1(this: *const @This()) !?i64 {
    var it = mem.tokenizeScalar(u8, this.input, '\n');
    var m = std.ArrayList([]const u8).init(this.allocator);
    defer m.deinit();

    while (it.next()) |line| {
        if (line.len == 0) continue;
        try m.append(line);
    }
    var count: i64 = 0;
    const n_rows = m.items.len;
    const n_cols = m.items[0].len;
    for (0..n_rows) |i| {
        for (0..n_cols) |j| {
            if (m.items[i][j] != 'X') {
                continue;
            }
            if (checkBound(Dir.U, i, j, 3, n_rows, n_cols) and check(Dir.U, i, j, 1, "XMAS", m)) {
                count += 1;
            }
            if (checkBound(Dir.UL, i, j, 3, n_rows, n_cols) and check(Dir.UL, i, j, 1, "XMAS", m)) {
                count += 1;
            }
            if (checkBound(Dir.UR, i, j, 3, n_rows, n_cols) and check(Dir.UR, i, j, 1, "XMAS", m)) {
                count += 1;
            }
            if (checkBound(Dir.D, i, j, 3, n_rows, n_cols) and check(Dir.D, i, j, 1, "XMAS", m)) {
                count += 1;
            }
            if (checkBound(Dir.DL, i, j, 3, n_rows, n_cols) and check(Dir.DL, i, j, 1, "XMAS", m)) {
                count += 1;
            }
            if (checkBound(Dir.DR, i, j, 3, n_rows, n_cols) and check(Dir.DR, i, j, 1, "XMAS", m)) {
                count += 1;
            }
            if (checkBound(Dir.L, i, j, 3, n_rows, n_cols) and check(Dir.L, i, j, 1, "XMAS", m)) {
                count += 1;
            }
            if (checkBound(Dir.R, i, j, 3, n_rows, n_cols) and check(Dir.R, i, j, 1, "XMAS", m)) {
                count += 1;
            }
        }
    }

    return count;
}

pub fn part2(this: *const @This()) !?i64 {
    var it = mem.tokenizeScalar(u8, this.input, '\n');
    var m = std.ArrayList([]const u8).init(this.allocator);
    defer m.deinit();

    while (it.next()) |line| {
        if (line.len == 0) continue;
        try m.append(line);
    }
    var count: i64 = 0;
    const n_rows = m.items.len;
    const n_cols = m.items[0].len;

    for (1..n_rows - 1) |r| {
        for (1..n_cols - 1) |c| {
            if (m.items[r][c] == 'A' and
                ((m.items[r - 1][c - 1] == 'M' and m.items[r + 1][c + 1] == 'S') or
                (m.items[r - 1][c - 1] == 'S' and m.items[r + 1][c + 1] == 'M')) and
                ((m.items[r - 1][c + 1] == 'M' and m.items[r + 1][c - 1] == 'S') or
                (m.items[r - 1][c + 1] == 'S' and m.items[r + 1][c - 1] == 'M')))
            {
                count += 1;
            }
        }
    }

    return count;
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
