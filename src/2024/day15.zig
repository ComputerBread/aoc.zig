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

const in2 =
    \\#######
    \\#...#.#
    \\#.....#
    \\#..OO@#
    \\#..O..#
    \\#.....#
    \\#######
    \\
    \\<vv<<^^<<^^
;

const WIDTH: usize = 7;
const HEIGHT: usize = 7;

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
    box_L,
    box_R,
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

    fn moveRobot(self: *Grid, pos: Pos, dir: Dir) Pos {
        const next_pos = switch (dir) {
            .UP => Pos{ pos[0] - 1, pos[1] },
            .RIGHT => Pos{ pos[0], pos[1] + 1 },
            .DOWN => Pos{ pos[0] + 1, pos[1] },
            .LEFT => Pos{ pos[0], pos[1] - 1 },
        };

        if (self.g[next_pos[0]][next_pos[1]] == Type.block) {
            return pos;
        }

        // if a box
        // then DFS to check if we can move all boxes
        // if we can't we exit
        // if we can move all boxes, then DFS again to move the moveable boxes
        if (self.g[next_pos[0]][next_pos[1]] == Type.box_R) {
        // check move box

        self.g[next_pos[0]][next_pos[1]] = .robot;
        self.g[pos[0]][pos[1]] = Type.empty;
        return next_pos;
    }

    fn moveBox(self: *Grid, pos: BigBoxPos, dir: Dir) BigBoxPos {
        // temporary
        self.g[pos[0]][pos[1]] = Type.empty;
        self.g[pos[2]][pos[3]] = Type.empty;

        if (dir == Dir.UP or dir == Dir.DOWN) {
            if (self.g[next_pos[0]][next_pos[1]] == .block or self.g[next_pos[2]][next_pos[3]] == .block) {
                return pos;
            }

            if (self.g[next_pos[0]][next_pos[1]] == .box_L and self.g[next_pos[2]][next_pos[3]] == .box_R and @reduce(.And, self.moveBox(next_pos, dir) == next_pos)) {
                return pos;
            }
        }
        //if (self.g[next_pos[0]][next_post[1]])
        return pos;
    }
};

const BigBoxPos = @Vector(4, usize);
const BigBox = struct {
    pos: BigBoxPos,

    fn nextPos(self: BigBox, dir: Dir) BigBoxPos {
        return switch (dir) {
            .UP => BigBoxPos{ self.pos[0] - 1, self.pos[1], self.pos[2] - 1, self.pos[3] },
            .RIGHT => BigBoxPos{ self.pos[0], self.pos[1] + 1, self.pos[2], self.pos[3] + 1 },
            .DOWN => BigBoxPos{ self.pos[0] + 1, self.pos[1], self.pos[2] + 1, self.pos[3] },
            .LEFT => BigBoxPos{ self.pos[0], self.pos[1] - 1, self.pos[2], self.pos[3] - 1 },
        };
    }

    fn canMoveForward(self: BigBox, grid: Grid, dir: Dir) bool {
        const np = self.nextPos(dir);
        return switch (dir) {
            .UP => {
                return grid[np[0]][np[1]] == .empty and grid[np[2]][np[3]] == .empty;
            },
            .RIGHT => {
                return grid[np[2]][np[3]] == .empty;
            },
            .DOWN => {
                return grid[np[0]][np[1]] == .empty and grid[np[2]][np[3]] == .empty;
            },
            .LEFT => {
                return grid[np[0]][np[1]] == .empty;
            },
        };
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
