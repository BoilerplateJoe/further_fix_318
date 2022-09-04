const std = @import("std");

pub const Error = error{
    NotInitialized,
    NoCurrentContext,
    InvalidEnum,
    InvalidValue,
    OutOfMemory,
    APIUnavailable,
    VersionUnavailable,
    PlatformError,
    FormatUnavailable,
    NoWindowContext,
    Unknown,
};

pub const Monitor = *opaque {
    pub const getPos = glfwGetMonitorPos;
    extern fn glfwGetMonitorPos(monitor: Monitor, xpos: *i32, ypos: *i32) void;
};

pub const getPrimaryMonitor = glfwGetPrimaryMonitor;
extern fn glfwGetPrimaryMonitor() ?Monitor;

pub fn getMonitors() ?[]Monitor {
    var count: i32 = 0;
    if (glfwGetMonitors(&count)) |monitors| {
        return monitors[0..@intCast(usize, count)];
    }
    return null;
}
extern fn glfwGetMonitors(count: *i32) ?[*]Monitor;

pub const Window = *opaque {
    pub fn shouldClose(window: Window) bool {
        return if (glfwWindowShouldClose(window) == 0) false else true;
    }
    extern fn glfwWindowShouldClose(window: Window) i32;
};

pub fn createWindow(
    width: i32,
    height: i32,
    title: [*:0]const u8,
    monitor: ?Monitor,
    share: ?Window,
) Error!Window {
    const window = glfwCreateWindow(width, height, title, monitor, share);
    if (window == null) {
        try getError();
    }
    return window.?;
}
extern fn glfwCreateWindow(
    width: i32,
    height: i32,
    title: [*:0]const u8,
    monitor: ?Monitor,
    share: ?Window,
) ?Window;

pub fn init() Error!void {
    if (glfwInit() == 0) {
        try getError();
    }
}
extern fn glfwInit() i32;

pub const terminate = glfwTerminate;
extern fn glfwTerminate() void;

pub fn getError() Error!void {
    return switch (glfwGetError(null)) {
        0 => {},
        0x00010001 => Error.NotInitialized,
        0x00010002 => Error.NoCurrentContext,
        0x00010003 => Error.InvalidEnum,
        0x00010004 => Error.InvalidValue,
        0x00010005 => Error.OutOfMemory,
        0x00010006 => Error.APIUnavailable,
        0x00010007 => Error.VersionUnavailable,
        0x00010008 => Error.PlatformError,
        0x00010009 => Error.FormatUnavailable,
        0x0001000A => Error.NoWindowContext,
        else => Error.Unknown,
    };
}
extern fn glfwGetError(description: ?*?[*:0]const u8) i32;

const expect = std.testing.expect;

test "zglfw.basic" {
    try init();
    defer terminate();

    const primary_monitor = getPrimaryMonitor();
    if (primary_monitor) |pm| {
        const monitors = getMonitors().?;
        try expect(pm == monitors[0]);
    }

    const window = try createWindow(200, 200, "test", null, null);
    _ = window;
}
