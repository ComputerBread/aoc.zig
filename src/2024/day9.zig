const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

//const in = "2333133121414131402";
pub fn part1(this: *const @This()) !?i64 {
    var blocks = std.ArrayList(usize).init(this.allocator);
    defer blocks.deinit();
    const in = this.input;

    var n: usize = 0;
    var f: usize = 0;
    for (0..in.len) |i| {
        if ('0' > in[i] or in[i] > '9') continue;
        const nb = in[i] - '0';
        if (i % 2 == 0) {
            for (0..nb) |_| {
                try blocks.append(n);
            }
            n += 1;
        } else {
            f += 1;
        }
    }

    var checksum: usize = 0;
    var id: usize = 0;
    var first: usize = 0;

    outer: for (0..in.len) |i| {
        if ('0' > in[i] or in[i] > '9') continue;
        const nb = in[i] - '0';
        if (i % 2 == 0) { // block
            for (0..nb) |_| {
                if (first >= blocks.items.len) break :outer;
                checksum += id * blocks.items[first];
                first += 1;
                id += 1;
            }
        } else { // free space
            for (0..nb) |_| {
                const b = blocks.popOrNull();
                if (b == null or first > blocks.items.len) break :outer;
                checksum += id * b.?;
                id += 1;
            }
        }
    }

    return @intCast(checksum);
}

const Block = struct {
    num: usize,
    quantity: u8,
};

pub fn part2(this: *const @This()) !?i64 {
    const in = this.input;
    // const in = "2333133121414131402";

    var blocks = std.ArrayList(Block).init(this.allocator);
    defer blocks.deinit();

    var n: usize = 0;
    for (0..in.len) |i| {
        if ('0' > in[i] or in[i] > '9') continue;
        if (i % 2 == 0) {
            const nb = in[i] - '0';
            try blocks.append(.{ .num = n, .quantity = nb });
            n += 1;
        }
    }
    var checksum: usize = 0;
    var last = blocks.items.len - 1;
    var index: usize = 0;
    var id: usize = 0;

    for (0..in.len) |i| {
        if ('0' > in[i] or in[i] > '9') continue;
        var nb = in[i] - '0';
        if (i % 2 == 0) {
            const qty = blocks.items[index].quantity;
            const num = blocks.items[index].num;
            for (0..qty) |_| {
                checksum += id * num;
                id += 1;
            }
            if (qty == 0) { // if it was moved
                id += nb;
            }
            index += 1;
        } else {
            while (last >= index and nb > 0) {
                const qty = blocks.items[last].quantity;
                const num = blocks.items[last].num;
                if (qty != 0 and qty <= nb) {
                    for (0..qty) |_| {
                        checksum += id * num;
                        id += 1;
                    }
                    nb -= qty;
                    blocks.items[last].quantity = 0;
                }
                last -= 1;
            }
            id += nb;
            last = blocks.items.len - 1;
        }
    }

    return @intCast(checksum);
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
