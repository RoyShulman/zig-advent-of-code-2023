const std = @import("std");

pub fn print(comptime fmt: []const u8, args: anytype) void {
    const stdout = std.io.getStdOut().writer();
    stdout.print(fmt, args) catch @panic("failed to write to stdout");
}
