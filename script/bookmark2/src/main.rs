use std::fs::File;
// use std::fs;
// use std::path::Path;
use std::io::prelude::*;
use std::env;
use std::io;
use std::process::Command;

fn main()  {
    // let mut echo_hello = Command::new("sh");
    // echo_hello.arg("-c").arg("echo hello");
    // let mut out = echo_hello.output().expect("failed to execute process");
    // io::stdout().write_all(&out.stdout).unwrap();
    // println!("Hello, world!");
    let home = env::var("HOME");
    // println!("{:?}", home);
    let home = String::from(home.unwrap());
    let bookmarks=format!("{}/bookmarks.txt", home);
    // println!("Bookmarks = {bookmarks}");
    // Running fzf
    let mut fzf = Command::new("bash");
    println!("Command = sort {} | fzf +s | cut -d | -f 2 | xargs open", bookmarks);
    fzf.arg("-c").arg(format!("sort {} | fzf +s | cut -d | -f 2 | xargs open", bookmarks)).spawn();
    let mut fzf_out = fzf.output().expect("FZF failed");
    // io::stdout().write_all(&fzf_out.stdout).unwrap();
    // io::stderr().write_all(&fzf_out.stderr).unwrap();

    // Open the name in read mode
    // let mut f = File::open(bookmarks)?;
    // let mut buffer = String::new();
    // f.read_to_string(&mut buffer)?;
    // println!("{}", buffer);
    // Ok(())
}

