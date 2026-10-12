//! Gruvbox dark hard. Every color the program prints comes from this table,
//! so another theme is a change to this file only.

use std::io::IsTerminal;

#[derive(Clone, Copy)]
pub enum Role {
    Ok,
    Warn,
    Fail,
    Push,
    Count,
    Dim,
    Spinner,
}

/// (truecolor RGB, nearest xterm-256 index) per role.
const fn palette(role: Role) -> ((u8, u8, u8), u8) {
    match role {
        Role::Ok => ((0xb8, 0xbb, 0x26), 142),
        Role::Warn => ((0xfa, 0xbd, 0x2f), 214),
        Role::Fail => ((0xfb, 0x49, 0x34), 167),
        Role::Push => ((0x83, 0xa5, 0x98), 109),
        Role::Count => ((0x8e, 0xc0, 0x7c), 108),
        Role::Dim => ((0x92, 0x83, 0x74), 245),
        Role::Spinner => ((0xfe, 0x80, 0x19), 208),
    }
}

#[derive(Clone, Copy, PartialEq)]
enum Depth {
    None,
    Ansi256,
    TrueColor,
}

/// Color support for one output stream.
#[derive(Clone, Copy)]
pub struct Theme {
    depth: Depth,
}

impl Theme {
    /// Colors are on when the stream is a terminal and NO_COLOR is unset.
    pub fn for_stream(is_terminal: bool) -> Self {
        let depth = if !is_terminal || std::env::var_os("NO_COLOR").is_some() {
            Depth::None
        } else {
            match std::env::var("COLORTERM").as_deref() {
                Ok("truecolor") | Ok("24bit") => Depth::TrueColor,
                _ => Depth::Ansi256,
            }
        };
        Theme { depth }
    }

    pub fn stdout() -> Self {
        Self::for_stream(std::io::stdout().is_terminal())
    }

    pub fn stderr() -> Self {
        Self::for_stream(std::io::stderr().is_terminal())
    }

    pub fn enabled(&self) -> bool {
        self.depth != Depth::None
    }

    pub fn paint(&self, role: Role, text: &str) -> String {
        let ((r, g, b), index) = palette(role);
        match self.depth {
            Depth::None => text.to_string(),
            Depth::TrueColor => format!("\x1b[38;2;{r};{g};{b}m{text}\x1b[0m"),
            Depth::Ansi256 => format!("\x1b[38;5;{index}m{text}\x1b[0m"),
        }
    }

    pub fn bold(&self, text: &str) -> String {
        if self.enabled() {
            format!("\x1b[1m{text}\x1b[0m")
        } else {
            text.to_string()
        }
    }

    /// indicatif style fragment: a 256-color index, as in "{spinner:.208}".
    pub fn indicatif(&self, role: Role) -> String {
        palette(role).1.to_string()
    }
}
