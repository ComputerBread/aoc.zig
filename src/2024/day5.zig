const std = @import("std");
const mem = std.mem;

input: []const u8,
allocator: mem.Allocator,

// THIS SHIT IS NOT WORKING FOR SOME REASON :'(
// but already spent waaaaay to much time on this shit!
// idk, smth's wrong w/ the hashmaps
pub fn part1_old(this: *const @This()) !?i64 {
    var it = mem.tokenizeSequence(u8, this.input, "\n\n");
    const rulesIn = it.next().?;
    const updatesIn = it.next().?;

    var rules = std.AutoHashMap(i64, std.AutoHashMap(i64, bool)).init(this.allocator);
    defer rules.deinit();

    var rulesIt = mem.tokenizeScalar(u8, rulesIn, '\n');
    while (rulesIt.next()) |ruleLine| {
        var rule = mem.tokenizeScalar(u8, ruleLine, '|');
        const before = try std.fmt.parseInt(i64, rule.next().?, 10);
        const after = try std.fmt.parseInt(i64, rule.next().?, 10);
        if (rules.contains(before)) {
            var r = rules.get(before).?;
            try r.put(after, true);
        } else {
            var r = std.AutoHashMap(i64, bool).init(this.allocator);
            try r.put(after, true);
            try rules.put(before, r);
        }
    }

    var updatesLinesIt = mem.tokenizeScalar(u8, updatesIn, '\n');
    var res: i64 = 0;
    outer: while (updatesLinesIt.next()) |updatesLines| {
        var list = std.ArrayList(i64).init(this.allocator);
        defer list.deinit();

        var updatesIt = mem.tokenizeScalar(u8, updatesLines, ',');
        while (updatesIt.next()) |update| {
            const num = try std.fmt.parseInt(i64, update, 10);

            // check rules
            if (rules.contains(num)) {
                const rm = rules.get(num).?;
                for (list.items) |el| {
                    if (rm.contains(el)) { // breaking the rule
                        std.debug.print("line: {s} is breaking rule {}|{}\n", .{ updatesLines, num, el });
                        continue :outer;
                    }
                }
            }

            try list.append(num);
        }
        // update is ok
        const index = @divTrunc(list.items.len, 2);
        res += list.items[index];
        std.debug.print("line: {s} is ok, middle {} res {}\n", .{ updatesLines, list.items[index], res });
    }

    // deinit inside of rules
    var cleaningRulesIt = rules.iterator();
    while (cleaningRulesIt.next()) |ruleMap| {
        ruleMap.value_ptr.deinit();
    }
    return res;
}

pub fn part1(this: *const @This()) !?i64 {
    var it = mem.tokenizeSequence(u8, this.input, "\n\n");
    const rulesIn = it.next().?;
    const updatesIn = it.next().?;

    var rules = [_][100]bool{[_]bool{false} ** 100} ** 100;

    var rulesIt = mem.tokenizeScalar(u8, rulesIn, '\n');
    while (rulesIt.next()) |ruleLine| {
        var rule = mem.tokenizeScalar(u8, ruleLine, '|');
        const before = try std.fmt.parseInt(usize, rule.next().?, 10);
        const after = try std.fmt.parseInt(usize, rule.next().?, 10);
        rules[before][after] = true;
    }

    var updatesLinesIt = mem.tokenizeScalar(u8, updatesIn, '\n');
    var res: i64 = 0;
    outer: while (updatesLinesIt.next()) |updatesLines| {
        var list = std.ArrayList(usize).init(this.allocator);
        defer list.deinit();

        var updatesIt = mem.tokenizeScalar(u8, updatesLines, ',');
        while (updatesIt.next()) |update| {
            const num = try std.fmt.parseInt(usize, update, 10);

            // check rules
            for (list.items) |el| {
                if (rules[num][el]) { // breaking the rule
                    std.debug.print("line: {s} is breaking rule {}|{}\n", .{ updatesLines, num, el });
                    continue :outer;
                }
            }

            try list.append(num);
        }
        // update is ok
        const index = @divTrunc(list.items.len, 2);
        res += @intCast(list.items[index]);
        std.debug.print("line: {s} is ok, middle {} res {}\n", .{ updatesLines, list.items[index], res });
    }
    return res;
}

var rules2 = [_][100]bool{[_]bool{false} ** 100} ** 100;

pub fn part2(this: *const @This()) !?i64 {
    var it = mem.tokenizeSequence(u8, this.input, "\n\n");
    const rulesIn = it.next().?;
    const updatesIn = it.next().?;

    var rulesIt = mem.tokenizeScalar(u8, rulesIn, '\n');
    while (rulesIt.next()) |ruleLine| {
        var rule = mem.tokenizeScalar(u8, ruleLine, '|');
        const before = try std.fmt.parseInt(usize, rule.next().?, 10);
        const after = try std.fmt.parseInt(usize, rule.next().?, 10);
        rules2[before][after] = true;
    }

    var updatesLinesIt = mem.tokenizeScalar(u8, updatesIn, '\n');
    var res: i64 = 0;
    while (updatesLinesIt.next()) |updatesLines| {
        var list = std.ArrayList(usize).init(this.allocator);
        defer list.deinit();

        var updatesIt = mem.tokenizeScalar(u8, updatesLines, ',');
        var isCorrect = true;
        while (updatesIt.next()) |update| {
            const num = try std.fmt.parseInt(usize, update, 10);

            // check rules
            for (list.items) |el| {
                if (rules2[num][el]) { // breaking the rule
                    isCorrect = false;
                }
            }

            try list.append(num);
        }
        if (!isCorrect) {
            std.mem.sort(usize, list.items, {}, cmp);
            const index = @divTrunc(list.items.len, 2);
            res += @intCast(list.items[index]);
        }
    }
    return res;
}

fn cmp(_: void, a: usize, b: usize) bool {
    return !rules2[b][a];
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
