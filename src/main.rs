use serde_json::{from_str, Value};
use std::{env, fs, io, path::Path, process};
use text_io::read;

fn read_json(path: &Path) -> Result<Value, io::Error> {
    let data = fs::read_to_string(path);
    match data {
        Ok(file) => {
            println!("{}", file);
            // transforme file to base64
            Ok(from_str(&file).unwrap())
        }
        Err(e) => {
            println!("error: {:?}", e);
            Err(e)
        }
    }
}

fn copy_file(from: &Path, to: &Path) -> io::Result<()> {
    println!("copying {:?} to {:?}", from, to);
    if let Some(p) = from.parent() {
        fs::create_dir_all(p)?
    };
    if let Some(p) = to.parent() {
        fs::create_dir_all(p)?
    };
    fs::copy(from, to)?;
    Ok(())
}

fn copy_dir_all(src: impl AsRef<Path>, dst: impl AsRef<Path>) -> io::Result<()> {
    println!("copying directory");
    fs::create_dir_all(&dst)?;
    for entry in fs::read_dir(src)? {
        let entry = entry?;
        let ty = entry.file_type()?;
        if ty.is_dir() {
            copy_dir_all(entry.path(), dst.as_ref().join(entry.file_name()))?;
        } else {
            fs::copy(entry.path(), dst.as_ref().join(entry.file_name()))?;
        }
    }
    Ok(())
}

fn main() {
    println!("Do you want to:");
    println!("  1) Update git repo with your current config files");
    println!("  2) Copy this repo's config files to your system");
    let user_input: i32 = read!();
    if ![1, 2].contains(&user_input) {
        println!("Please try again and input 1 or 2");
        process::exit(1);
    }
    let json_data = read_json(Path::new("./dotfiles_paths.json")).unwrap();
    let choice = match user_input {
        1 => "copy your system files to this git repository",
        2 => "copy this git repository's files to your system",
        _ => "",
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
        let is_dir = &git_file.as_str().ends_with('/');
        let os_file_path = &os_file
            .as_str()
            .unwrap()
            .replace('~', &env::var("HOME").unwrap());
        let (from, to) = match user_input {
            1 => (os_file_path, git_file),
            _ => (git_file, os_file_path),
        };
        let res = match is_dir {
            true => copy_dir_all(Path::new(from), Path::new(to)),
            false => copy_file(Path::new(from), Path::new(to)),
        };
        match res {
            Ok(_) => println!("File successfully copied"),
            Err(e) => println!("Error while copying file, {:?}", e),
        };
    }
}
