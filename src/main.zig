const std = @import("std");
const time = std.time;
const epoch = time.epoch;

const raylib = @cImport(
    @cInclude("raylib.h"),
);

const raymath = @cImport(
    @cInclude("raymath.h"),
);

const green = raylib.struct_Color{
    .a = 255,
    .r = 0,
    .g = 255,
    .b = 0,
};

const black = raylib.struct_Color{
    .a = 0,
    .r = 0,
    .g = 0,
    .b = 0,
};

const DayStrings = [_][]const u8{
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
};

const MonthStrings = [_][]const u8{
    "day of the end times",
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
};

pub fn main() !void {
    raylib.InitWindow(
        raylib.GetScreenWidth(),
        raylib.GetScreenHeight(),
        "Time Kiosk",
    );
    defer raylib.CloseWindow();

    raylib.SetTargetFPS(1);
    raylib.ToggleFullscreen();

    var looping: bool = true;

    const time_fontsize = getMaximumFontSize("55:55:55");
    const date_fontsize = getMaximumFontSize("Saturday - 35 September");
    const week_fontsize = getMaximumFontSize("Week 55");

    var buffer: [128:0]u8 = undefined;
    var writer = std.io.Writer.fixed(&buffer);

    while (!raylib.WindowShouldClose() and looping) {
        raylib.BeginDrawing();
        defer raylib.ClearBackground(black);
        defer raylib.EndDrawing();
        defer writer.end = 0;

        const key = raylib.GetKeyPressed();
        defer switch (key) {
            raylib.KEY_Q => looping = !looping,
            else => {},
        };

        const ts = std.time.timestamp();
        const es = epoch.EpochSeconds{ .secs = @intCast(ts) };
        const ed = es.getEpochDay();
        const yd = ed.calculateYearDay();
        const md = yd.calculateMonthDay();
        const ds = es.getDaySeconds();
        const day_of_the_week: usize = @intCast(@mod(@divTrunc(ts, epoch.secs_per_day) + 3, 7));
        const week_number = @divTrunc(yd.day, 7) + 1;

        try writer.print("{d:02}:{d:02}:{d:02}", .{
            ds.getHoursIntoDay(),
            ds.getMinutesIntoHour(),
            ds.getSecondsIntoMinute(),
        });
        try writer.writeByte(0);
        var measure = raylib.MeasureText(&buffer, time_fontsize);
        var padding = @divTrunc(raylib.GetScreenWidth() - measure, 2);
        raylib.DrawText(
            &buffer,
            padding,
            0,
            time_fontsize,
            green,
        );

        writer.end = 0;

        try writer.print("{s} - {d} {s}", .{
            DayStrings[day_of_the_week],
            md.day_index,
            MonthStrings[md.month.numeric()],
        });
        try writer.writeByte(0);
        measure = raylib.MeasureText(&buffer, date_fontsize);
        padding = @divTrunc(raylib.GetScreenWidth() - measure, 2);
        raylib.DrawText(
            &buffer,
            padding,
            time_fontsize,
            date_fontsize,
            green,
        );

        writer.end = 0;

        try writer.print("Week {d}", .{week_number});
        try writer.writeByte(0);
        measure = raylib.MeasureText(&buffer, week_fontsize);
        padding = @divTrunc(raylib.GetScreenWidth() - measure, 2);
        raylib.DrawText(
            &buffer,
            padding,
            time_fontsize + date_fontsize,
            week_fontsize,
            green,
        );
    }
}

fn getMaximumFontSize(text: [*c]const u8) i32 {
    var temp_font_size: i32 = 1;
    var temp_size: i32 = 0;
    while (temp_size < raylib.GetScreenWidth()) {
        temp_size = raylib.MeasureText(text, temp_font_size);
        temp_font_size += 1;
    }
    return temp_font_size - 1;
}
