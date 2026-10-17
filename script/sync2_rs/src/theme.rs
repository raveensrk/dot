//! Color themes: Ayu Dark (default) and Gruvbox Dark Hard. Every color the
//! program draws comes from these tables, so another theme is a new
//! `Palette` here plus an entry in `Name::ALL`.

use std::io::IsTerminal;

pub type Rgb = (u8, u8, u8);

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

pub struct Palette {
    pub bg: Rgb,
    pub panel: Rgb,
    pub fg: Rgb,
    pub dim: Rgb,
    pub border: Rgb,
    pub select: Rgb,
    pub ok: Rgb,
    pub warn: Rgb,
    pub fail: Rgb,
    pub push: Rgb,
    pub count: Rgb,
    pub accent: Rgb,
}

impl Palette {
    pub fn role(&self, role: Role) -> Rgb {
        match role {
            Role::Ok => self.ok,
            Role::Warn => self.warn,
            Role::Fail => self.fail,
            Role::Push => self.push,
            Role::Count => self.count,
            Role::Dim => self.dim,
            Role::Spinner => self.accent,
        }
    }
}

const AYU_DARK: Palette = Palette {
    bg: (0x0b, 0x0e, 0x14),
    panel: (0x0f, 0x13, 0x1a),
    fg: (0xbf, 0xbd, 0xb6),
    dim: (0x56, 0x5b, 0x66),
    border: (0x24, 0x29, 0x36),
    select: (0x1b, 0x3a, 0x5b),
    ok: (0xaa, 0xd9, 0x4c),
    warn: (0xff, 0xb4, 0x54),
    fail: (0xf0, 0x71, 0x78),
    push: (0x59, 0xc2, 0xff),
    count: (0x95, 0xe6, 0xcb),
    accent: (0xe6, 0xb4, 0x50),
};

const GRUVBOX_DARK_HARD: Palette = Palette {
    bg: (0x1d, 0x20, 0x21),
    panel: (0x28, 0x28, 0x28),
    fg: (0xeb, 0xdb, 0xb2),
    dim: (0x92, 0x83, 0x74),
    border: (0x50, 0x49, 0x45),
    select: (0x3c, 0x38, 0x36),
    ok: (0xb8, 0xbb, 0x26),
    warn: (0xfa, 0xbd, 0x2f),
    fail: (0xfb, 0x49, 0x34),
    push: (0x83, 0xa5, 0x98),
    count: (0x8e, 0xc0, 0x7c),
    accent: (0xfe, 0x80, 0x19),
};

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Name {
    Ayu,
    Gruvbox,
}

impl Name {
    pub const ALL: [Name; 2] = [Name::Ayu, Name::Gruvbox];

    pub fn key(self) -> &'static str {
        match self {
            Name::Ayu => "ayu",
            Name::Gruvbox => "gruvbox",
        }
    }

    pub fn label(self) -> &'static str {
        match self {
            Name::Ayu => "Ayu Dark",
            Name::Gruvbox => "Gruvbox Dark Hard",
        }
    }

    pub fn parse(key: &str) -> Option<Name> {
        Name::ALL.into_iter().find(|n| n.key() == key)
    }

    pub fn next(self) -> Name {
        let i = Name::ALL.iter().position(|n| *n == self).unwrap_or(0);
        Name::ALL[(i + 1) % Name::ALL.len()]
    }

    pub fn palette(self) -> &'static Palette {
        match self {
            Name::Ayu => &AYU_DARK,
            Name::Gruvbox => &GRUVBOX_DARK_HARD,
        }
    }
}

#[derive(Clone, Copy, PartialEq)]
enum Depth {
    None,
    Ansi256,
    TrueColor,
}

/// Nearest xterm-256 color-cube index.
fn ansi256((r, g, b): Rgb) -> u8 {
    let c = |v: u8| ((v as u16 * 5 + 127) / 255) as u8;
    16 + 36 * c(r) + 6 * c(g) + c(b)
}

/// ANSI painter for the report printed after the TUI closes.
#[derive(Clone, Copy)]
pub struct Theme {
    depth: Depth,
    name: Name,
}

impl Theme {
    /// Colors are on when the stream is a terminal and NO_COLOR is unset.
    pub fn for_stream(is_terminal: bool, name: Name) -> Self {
        let depth = if !is_terminal || std::env::var_os("NO_COLOR").is_some() {
            Depth::None
        } else {
            match std::env::var("COLORTERM").as_deref() {
                Ok("truecolor") | Ok("24bit") => Depth::TrueColor,
                _ => Depth::Ansi256,
            }
        };
        Theme { depth, name }
    }

    pub fn stdout(name: Name) -> Self {
        Self::for_stream(std::io::stdout().is_terminal(), name)
    }

    pub fn stderr(name: Name) -> Self {
        Self::for_stream(std::io::stderr().is_terminal(), name)
    }

    pub fn paint(&self, role: Role, text: &str) -> String {
        let rgb @ (r, g, b) = self.name.palette().role(role);
        match self.depth {
            Depth::None => text.to_string(),
            Depth::TrueColor => format!("\x1b[38;2;{r};{g};{b}m{text}\x1b[0m"),
            Depth::Ansi256 => format!("\x1b[38;5;{}m{text}\x1b[0m", ansi256(rgb)),
        }
    }

    pub fn bold(&self, text: &str) -> String {
        if self.depth != Depth::None {
            format!("\x1b[1m{text}\x1b[0m")
        } else {
            text.to_string()
        }
    }
}
