const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

// from studying a bit the input file (is that cheating?)
// there is 36 nodes: K,A,D,6,d,4,e,T,B,k,w,y,g,Q,b,W,1,0,a,3,7,m,I,V,9,t,E,v,i,M,2,q,Y,5,8,G
// Max code point is 121, min is 48
// source: 75,65,68,54,100,52,101,84,66,107,119,121,103,81,98,87,49,48,97,51,55,109,73,86,57,116,69,118,105,77,50,113,89,53,56,71
// there is 50 lines of 50 chars

const SIZE = 50;
const MIN_CODE = 48;
const MAX_CODE = 121;
const BitSetType = std.bit_set.StaticBitSet(MAX_CODE - MIN_CODE + 1);

const Grid = struct {
    g: [SIZE][SIZE]BitSetType,

    pub fn addAntiNode(self: *Grid, typ: u8, r: isize, c: isize) void {
        if (r < 0 or r >= SIZE or c < 0 or c >= SIZE) return;
        self.g[@intCast(r)][@intCast(c)].set(typ - MIN_CODE);
    }

    pub fn countAntiNodes(self: Grid) i64 {
        var count: usize = 0;
        for (0..SIZE) |r| {
            for (0..SIZE) |c| {
                //count += self.g[r][c].count();
                if (self.g[r][c].count() > 0) {
                    count += 1;
                }
            }
        }
        return @intCast(count);
    }

    pub fn setAntinodes(self: *Grid, a1: Antenna, a2: Antenna) void {
        if (a1.typ != a2.typ) return;
        const dr = a2.r - a1.r;
        const dc = a2.c - a1.c;
        self.addAntiNode(a1.typ, a1.r - dr, a1.c - dc);
        self.addAntiNode(a1.typ, a2.r + dr, a2.c + dc);
    }

    pub fn setAllAntinodes(self: *Grid, a1: Antenna, a2: Antenna) void {
        if (a1.typ != a2.typ) return;
        const dr = a2.r - a1.r;
        const dc = a2.c - a1.c;
        var i: isize = 0;
        while (inBound(a1.r - i * dr, a1.c - i * dc) or inBound(a2.r + i * dr, a2.c + dc)) : (i += 1) {
            self.addAntiNode(a1.typ, a1.r - i * dr, a1.c - i * dc);
            self.addAntiNode(a1.typ, a2.r + i * dr, a2.c + i * dc);
        }
    }

    fn inBound(r: isize, c: isize) bool {
        return r >= 0 and r < SIZE and c >= 0 and c < SIZE;
    }

    pub fn new() Grid {
        return Grid{
            .g = [_][SIZE]BitSetType{[_]BitSetType{BitSetType.initEmpty()} ** SIZE} ** SIZE,
        };
    }
};

const Antenna = struct {
    typ: u8,
    r: isize,
    c: isize,
    fn new(typ: u8, r: usize, c: usize) Antenna {
        return Antenna{
            .typ = typ,
            .r = @intCast(r),
            .c = @intCast(c),
        };
    }
};

pub fn part1(this: *const @This()) !?i64 {
    var lines = mem.tokenizeScalar(u8, this.input, '\n');
    var r: usize = 0;
    var grid = Grid.new();
    var list = std.ArrayList(Antenna).init(this.allocator);
    defer list.deinit();
    while (lines.next()) |line| : (r += 1) {
        for (line, 0..) |el, c| {
            if (el == '.') continue;
            const antenna = Antenna.new(el, r, c);
            try list.append(antenna);
        }
    }
    for (0..list.items.len) |i| {
        const n = i + 1;
        for (n..list.items.len) |j| {
            grid.setAntinodes(list.items[i], list.items[j]);
        }
    }
    return grid.countAntiNodes();
}

pub fn part2(this: *const @This()) !?i64 {
    var lines = mem.tokenizeScalar(u8, this.input, '\n');
    var r: usize = 0;
    var grid = Grid.new();
    var list = std.ArrayList(Antenna).init(this.allocator);
    defer list.deinit();
    while (lines.next()) |line| : (r += 1) {
        for (line, 0..) |el, c| {
            if (el == '.') continue;
            const antenna = Antenna.new(el, r, c);
            try list.append(antenna);
        }
    }
    for (0..list.items.len) |i| {
        const n = i + 1;
        for (n..list.items.len) |j| {
            grid.setAllAntinodes(list.items[i], list.items[j]);
        }
    }
    return grid.countAntiNodes();
}
