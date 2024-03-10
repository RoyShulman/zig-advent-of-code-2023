const std = @import("std");
const io_utils = @import("io_utils.zig");

pub fn main() !void {
    io_utils.print("{s}", .{"input please :)\n"});
    var input_buf: [1000000]u8 = undefined;
    const input = try read_input(&input_buf);

    const result = try part1(input);
    io_utils.print("part1: {d}\n", .{result});

    // const result2 = try part2(input);
    // io_utils.print("part2: {d}\n", .{result2});
}

const Game = struct {
    green: u8,
    red: u8,
    blue: u8,

    pub inline fn default() Game {
        return Game{ .blue = 0, .green = 0, .red = 0 };
    }

    fn is_game_possible(self: Game) bool {
        return (self.red <= 12 and self.green <= 13 and self.blue <= 14);
    }
};
const ParseError = error{ LineMissingGameIdPart, LineMissingGameDescription, MissingGameId, ColorTooShort, InvalidColor, ColorParseError };

fn part1(input: []const u8) !u32 {
    var it = std.mem.split(u8, input, "\n");
    var games_possible_sum: u32 = 0;

    while (it.next()) |line| {
        const game_id = try parse_single_line(line) orelse continue;
        games_possible_sum += game_id;
    }

    return games_possible_sum;
}

fn get_max_cubes(game1: Game, game2: Game) Game {
    return Game{ .blue = @max(game1.blue, game2.blue), .red = @max(game1.red, game2.red), .green = @max(game1.green, game2.green) };
}

fn parse_single_game(single_game: []const u8) !Game {
    var it = std.mem.splitScalar(u8, single_game, ',');
    var game = Game.default();
    while (it.next()) |count_color| {
        const count_color_stripped = std.mem.trim(u8, count_color, " ");
        var color_it = std.mem.splitScalar(u8, count_color_stripped, ' ');

        const num_str = color_it.next() orelse return error.ColorParseError;
        const color = color_it.next() orelse return error.ColorParseError;

        const num = try std.fmt.parseInt(u8, num_str, 10);
        if (std.mem.eql(u8, "red", color)) {
            game.red += num;
        } else if (std.mem.eql(u8, "green", color)) {
            game.green += num;
        } else if (std.mem.eql(u8, "blue", color)) {
            game.blue += num;
        } else {
            std.debug.print("{s} is not a valid color ({s})\n", .{ color, count_color_stripped });
            return error.InvalidColor;
        }
    }

    return game;
}

fn parse_game_description(game_description: []const u8) !Game {
    var total_game = Game.default();
    var it = std.mem.splitScalar(u8, game_description, ';');
    while (it.next()) |game| {
        const parsed_game = try parse_single_game(game);
        total_game = get_max_cubes(total_game, parsed_game);
    }

    return total_game;
}

fn parse_game_id(game_id_string: []const u8) !u32 {
    var it = std.mem.splitBackwardsScalar(u8, game_id_string, ' ');
    const game_id = it.next() orelse return error.MissingGameId;

    return try std.fmt.parseInt(u32, game_id, 10);
}

fn parse_single_line(line: []const u8) !?u32 {
    var it = std.mem.splitScalar(u8, line, ':');
    const game_id_string: []const u8 = it.next() orelse return error.LineMissingGameIdPart;
    const game_description_string: []const u8 = it.next() orelse return error.LineMissingGameDescription;

    const game_id = try parse_game_id(game_id_string);
    const game_description = try parse_game_description(game_description_string);
    if (game_description.is_game_possible()) {
        return game_id;
    } else {
        return null;
    }
}

fn read_input(input_buf: []u8) ![]u8 {
    const stdin = std.io.getStdIn();
    const read_bytes = try stdin.read(input_buf);
    std.debug.assert(read_bytes < input_buf.len);

    const input = input_buf[0..read_bytes];
    return input;
}

test "test part 1" {
    const input =
        \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    ;
    const result = try part1(input);
    try std.testing.expectEqual(@as(u32, 8), result);
}

test "test part 2" {}
