const std = @import("std");
const io_utils = @import("io_utils.zig");

pub fn main() !void {
    io_utils.print("{s}", .{"input please :)\n"});
    const stdin = std.io.getStdIn();
    var input_buf: [1000000]u8 = undefined;

    const read_bytes = try stdin.read(&input_buf);
    std.debug.assert(read_bytes < input_buf.len);

    const input = input_buf[0..read_bytes];

    const result = try part1(input);
    io_utils.print("part1: {d}\n", .{result});

    const result2 = try part2(input);
    io_utils.print("part2: {d}\n", .{result2});
}

const Day1Error = error{ LineLengthIsZero, NoDigitInLine };

fn find_first_digit(line: []const u8) ?u8 {
    for (line) |c| {
        if (std.ascii.isDigit(c)) {
            return c;
        }
    }
    return null;
}

fn find_last_digit(line: []const u8) ?u8 {
    var i = line.len;
    while (i > 0) {
        i -= 1;
        const c = line[i];
        if (std.ascii.isDigit(c)) {
            return c;
        }
    }
    return null;
}

fn part1(input: []const u8) !u32 {
    var it = std.mem.split(u8, input, "\n");
    var sum: u32 = 0;

    while (it.next()) |line| {
        if (line.len == 0) {
            return error.LineLengthIsZero;
        }

        const first_letter = find_first_digit(line) orelse return error.NoDigitInLine;
        const last_letter = find_last_digit(line) orelse return error.NoDigitInLine;

        const combined = [_]u8{ first_letter, last_letter };

        const number = std.fmt.parseInt(u8, &combined, 10) catch |err| {
            std.debug.print("failed to parse: {s}\n", .{combined});
            return err;
        };

        sum += number;
    }

    return sum;
}

const SPELLED_DIGITS = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };
const DigitWithIndex = struct { digit: u8, index: usize };

fn return_digit_with_compare_index(digit_with_index1: ?DigitWithIndex, digit_with_index2: ?DigitWithIndex, first: bool) ?u8 {
    if (digit_with_index1) |digit1| {
        if (digit_with_index2) |digit2| {
            if (first) {
                if (digit1.index < digit2.index) {
                    return digit1.digit;
                } else {
                    return digit2.digit;
                }
            } else {
                if (digit1.index > digit2.index) {
                    return digit1.digit;
                } else {
                    return digit2.digit;
                }
            }
        } else {
            return digit1.digit;
        }
    } else if (digit_with_index2) |digit2| {
        return digit2.digit;
    }

    return null;
}

///
/// Iterate over the line to find the first occurnce of either a numerical digit, or a
/// digit written in text like "one", "two",...
fn find_first_real_digit(line: []const u8) ?u8 {
    var digit_with_index: ?DigitWithIndex = null;
    for (line, 0..) |c, index| {
        if (std.ascii.isDigit(c)) {
            const digit = c - '0';
            digit_with_index = .{ .digit = digit, .index = index };
            break;
        }
    }

    var spelled_digit_with_index: ?DigitWithIndex = null;
    outer: for (0..line.len) |index| {
        for (SPELLED_DIGITS, 1..) |spelled_digit, digit_value| {
            const leftover_length = line.len - index;
            if (spelled_digit.len > leftover_length) {
                continue;
            }

            const to_compare_to = line[index .. index + spelled_digit.len];

            if (std.mem.eql(u8, spelled_digit, to_compare_to)) {
                std.debug.assert(digit_value <= std.math.maxInt(u8));
                spelled_digit_with_index = .{ .digit = @as(u8, @intCast(digit_value)), .index = index };
                break :outer;
            }
        }
    }

    return return_digit_with_compare_index(digit_with_index, spelled_digit_with_index, true);
}

fn find_last_real_digit(line: []const u8) ?u8 {
    var digit_with_index: ?DigitWithIndex = null;
    var i = line.len;
    while (i > 0) {
        i -= 1;
        const c = line[i];
        if (std.ascii.isDigit(c)) {
            const digit = c - '0';
            digit_with_index = DigitWithIndex{ .digit = digit, .index = i };
            break;
        }
    }

    var spelled_digit_with_index: ?DigitWithIndex = null;
    i = line.len;
    outer: while (i > 0) {
        i -= 1;

        for (SPELLED_DIGITS, 1..) |spelled_digit, digit_value| {
            const leftover_length = line.len - i;
            if (spelled_digit.len > leftover_length) {
                continue;
            }

            const to_compare_to = line[i .. i + spelled_digit.len];

            if (std.mem.eql(u8, spelled_digit, to_compare_to)) {
                std.debug.assert(digit_value <= std.math.maxInt(u8));
                spelled_digit_with_index = .{ .digit = @as(u8, @intCast(digit_value)), .index = i };
                break :outer;
            }
        }
    }

    return return_digit_with_compare_index(digit_with_index, spelled_digit_with_index, false);
}

fn part2(input: []const u8) !u32 {
    var it = std.mem.split(u8, input, "\n");
    var sum: u32 = 0;

    while (it.next()) |line| {
        if (line.len == 0) {
            return error.LineLengthIsZero;
        }

        const first_digit = find_first_real_digit(line) orelse return error.NoDigitInLine;
        const last_digit = find_last_real_digit(line) orelse return error.NoDigitInLine;

        const number = first_digit * 10 + last_digit;

        sum += number;
    }

    return sum;
}

test "test part 1" {
    const input =
        \\1abc2
        \\pqr3stu8vwx
        \\a1b2c3d4e5f
        \\treb7uchet
    ;
    const result = try part1(input);
    try std.testing.expectEqual(@as(u32, 142), result);
}

test "test part 2" {
    const input =
        \\two1nine
        \\eightwothree
        \\abcone2threexyz
        \\xtwone3four
        \\4nineeightseven2
        \\zoneight234
        \\7pqrstsixteen
    ;
    const result = try part2(input);
    try std.testing.expectEqual(@as(u32, 281), result);
}
