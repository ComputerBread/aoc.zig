const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

const Coordinates = struct {
    x: i64,
    y: i64,
};

const Entry = struct {
    button_a: Coordinates,
    button_b: Coordinates,
    prize: Coordinates,
};

pub fn parseCoordinates(allocator: std.mem.Allocator, input: []const u8) ![]Entry {
    var entries = std.ArrayList(Entry).init(allocator);
    defer entries.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var current_entry = Entry{
        .button_a = Coordinates{ .x = 0, .y = 0 },
        .button_b = Coordinates{ .x = 0, .y = 0 },
        .prize = Coordinates{ .x = 0, .y = 0 },
    };
    var button_a_parsed = false;
    var button_b_parsed = false;

    while (lines.next()) |line| {
        if (std.mem.startsWith(u8, line, "Button A:")) {
            const coords = try parseButtonCoordinates(line);
            current_entry.button_a = coords;
            button_a_parsed = true;
        } else if (std.mem.startsWith(u8, line, "Button B:")) {
            const coords = try parseButtonCoordinates(line);
            current_entry.button_b = coords;
            button_b_parsed = true;
        } else if (std.mem.startsWith(u8, line, "Prize:")) {
            const coords = try parsePrizeCoordinates(line);
            current_entry.prize = coords;

            // If we have both button coordinates, add the entry
            if (button_a_parsed and button_b_parsed) {
                try entries.append(current_entry);

                // Reset for next entry
                button_a_parsed = false;
                button_b_parsed = false;
                current_entry = Entry{
                    .button_a = Coordinates{ .x = 0, .y = 0 },
                    .button_b = Coordinates{ .x = 0, .y = 0 },
                    .prize = Coordinates{ .x = 0, .y = 0 },
                };
            }
        }
    }

    return entries.toOwnedSlice();
}

fn parseButtonCoordinates(line: []const u8) !Coordinates {
    var parts = std.mem.tokenizeSequence(u8, line, ": ");
    _ = parts.next(); // Skip "Button A" or "Button B"

    const ne = parts.next().?;
    parts = std.mem.tokenizeSequence(u8, ne, ", ");
    const x_str = parts.next() orelse return error.InvalidFormat;
    const y_str = parts.next() orelse return error.InvalidFormat;

    return Coordinates{
        .x = try std.fmt.parseInt(i64, x_str[2..], 10),
        .y = try std.fmt.parseInt(i64, y_str[2..], 10),
    };
}

fn parsePrizeCoordinates(line: []const u8) !Coordinates {
    var parts = std.mem.tokenizeSequence(u8, line, ": ");
    _ = parts.next(); // Skip "Prize"

    parts = std.mem.tokenizeSequence(u8, parts.next().?, ", ");
    const x_str = parts.next() orelse return error.InvalidFormat;
    const y_str = parts.next() orelse return error.InvalidFormat;

    return Coordinates{
        .x = try std.fmt.parseInt(i64, x_str[2..], 10),
        .y = try std.fmt.parseInt(i64, y_str[2..], 10),
    };
}

pub fn part1(this: *const @This()) !?i64 {
    const entries = try parseCoordinates(this.allocator, this.input);
    defer this.allocator.free(entries);

    var res: i64 = 0;
    for (entries) |entry| {
        const det = entry.button_a.x * entry.button_b.y - entry.button_a.y * entry.button_b.x;
        const A = @divTrunc((entry.prize.x * entry.button_b.y - entry.prize.y * entry.button_b.x), det);
        const B = @divTrunc((entry.prize.y * entry.button_a.x - entry.prize.x * entry.button_a.y), det);
        if ((entry.button_a.x * A + entry.button_b.x * B) == entry.prize.x and (entry.button_a.y * A + entry.button_b.y * B) == entry.prize.y) {
            res += A * 3 + B;
        }
    }
    return @intCast(res);
}

pub fn part2(this: *const @This()) !?i64 {
    const entries = try parseCoordinates(this.allocator, this.input);
    defer this.allocator.free(entries);

    var res: i64 = 0;
    for (entries) |*entry| {
        entry.prize.x += 10000000000000;
        entry.prize.y += 10000000000000;
        const det = entry.button_a.x * entry.button_b.y - entry.button_a.y * entry.button_b.x;
        const A = @divTrunc((entry.prize.x * entry.button_b.y - entry.prize.y * entry.button_b.x), det);
        const B = @divTrunc((entry.prize.y * entry.button_a.x - entry.prize.x * entry.button_a.y), det);
        if ((entry.button_a.x * A + entry.button_b.x * B) == entry.prize.x and (entry.button_a.y * A + entry.button_b.y * B) == entry.prize.y) {
            res += A * 3 + B;
        }
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
