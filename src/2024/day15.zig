const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const in =
    \\##########
    \\#..O..O.O#
    \\#......O.#
    \\#.OO..O.O#
    \\#..O@..O.#
    \\#O#..O...#
    \\#O..O..O.#
    \\#.OO.O.OO#
    \\#....O...#
    \\##########
    \\
    \\<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
    \\vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
    \\><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
    \\<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
    \\^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
    \\^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
    \\>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
    \\<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
    \\^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
    \\v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
;
const WIDTH: usize = 50;
const HEIGHT: usize = 50;

const Dir = enum {
    UP,
    DOWN,
    LEFT,
    RIGHT,
    fn fromU8(char: u8) !Dir {
        return switch (char) {
            '^' => Dir.UP,
            'v' => Dir.DOWN,
            '<' => Dir.LEFT,
            '>' => Dir.RIGHT,
            else => error.InvalidCharacter,
        };
    }
};

const Type = enum {
    box,
    block,
    empty,
    robot,
};

const Pos = @Vector(2, usize); // row, col

const Grid = struct {
    g: [HEIGHT][WIDTH]Type,

    fn moveForward(self: *Grid, pos: Pos, dir: Dir, typ: Type) Pos {
        const next_pos = switch (dir) {
            .UP => Pos{ pos[0] - 1, pos[1] },
            .RIGHT => Pos{ pos[0], pos[1] + 1 },
            .DOWN => Pos{ pos[0] + 1, pos[1] },
            .LEFT => Pos{ pos[0], pos[1] - 1 },
        };

        if (self.g[next_pos[0]][next_pos[1]] == Type.block) {
            return pos;
        }

        if (self.g[next_pos[0]][next_pos[1]] == Type.box and @reduce(.And, next_pos == self.moveForward(next_pos, dir, Type.box))) {
            return pos;
        }

        self.g[next_pos[0]][next_pos[1]] = typ;
        self.g[pos[0]][pos[1]] = Type.empty;
        return next_pos;
    }
};

pub fn part1(this: *const @This()) !?i64 {
    var it = mem.tokenizeSequence(u8, this.input, "\n\n");
    var gridit = mem.tokenizeScalar(u8, it.next().?, '\n');
    var grid = Grid{
        .g = [_][WIDTH]Type{[_]Type{Type.empty} ** WIDTH} ** HEIGHT,
    };
    var r: usize = 0;
    var robot: Pos = undefined;
    while (gridit.next()) |line| : (r += 1) {
        for (0..line.len) |c| {
            grid.g[r][c] = switch (line[c]) {
                '#' => Type.block,
                'O' => Type.box,
                else => Type.empty,
            };
            if (line[c] == '@') {
                robot = Pos{ r, c };
            }
        }
    }

    const moves = it.next().?;
    for (moves) |move| {
        if (move == '\n') continue;
        const dir = try Dir.fromU8(move);
        robot = grid.moveForward(robot, dir, Type.robot);
    }
    var res: usize = 0;
    for (0..HEIGHT) |rr| {
        for (0..WIDTH) |cc| {
            if (grid.g[rr][cc] == Type.box) {
                res += rr * 100 + cc;
            }
        }
    }
    return @intCast(res);
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
