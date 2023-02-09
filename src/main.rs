use std::{fs, io, env, process, path::Path};
use serde_json::{Value, from_str};
use text_io::read;

fn read_json(path: &Path) -> Result<Value, io::Error> {
    let data = fs::read_to_string(path);
    match data {
        Ok(file) => {
            println!("{}", file);
            Ok(from_str(&file).unwrap())
        },
        Err(e) => {
            println!("error: {:?}", e);
            return Err(e);
        }
    }
}

fn copy_file(from: &Path, to: &Path) -> Result<u64, io::Error> {
    println!("copying {:?} to {:?}", from, to);
    if let Some(p) = from.parent() {
        fs::create_dir_all(p)?
    };
    if let Some(p) = to.parent() {
        fs::create_dir_all(p)?
    };
    fs::copy(from, to)
}

fn main() {
    println!("Do you want to:");
    println!("  1) Update git repo with your current config files");
    println!("  2) Copy this repo's config files to your system");
    let user_input:i32 = read!();
    if ![1, 2].contains(&user_input) {
        println!("Please try again and input 1 or 2");
        process::exit(1);
    }
    let json_data = read_json(Path::new("./dotfiles_paths.json")).unwrap();
    let choice = match user_input {
        1 => "copy your system files to this git repository",
        2 => "copy this git repository's files to your system",
        _ => ""
    };
    println!("Do you confirm you want to {}? (y/N)", choice);
    let user_confirmation: String = read!();
    match user_confirmation.as_str() {
        "y" => (),
        _ => {
            println!("Aborting.");
            process::exit(1);
        }
    };
    for (git_file, os_file) in json_data.as_object().unwrap() {
        let os_file_path = &os_file.as_str().unwrap().replace('~', &env::var("HOME").unwrap());
        let (from, to) = match user_input {
            1 => (os_file_path, git_file),
            _ => (git_file, os_file_path)
        };
        let res = copy_file(Path::new(from), Path::new(to));
        match res {
            Ok(_) => println!("File successfully copied"),
            Err(e) => println!("Error while copying file, {:?}", e)
        };
    }
}
