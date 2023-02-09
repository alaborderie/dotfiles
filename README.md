# Manage your dotfiles with a simple rust script

This repo helps me sync my dotfiles between my computers.

## Usage

Clone/Fork this repo, update dotfiles_paths.json to match files you want to manage and their path (absolute, can use ~ for $HOME) and run `cargo run`.

Use option 1 to update this repo with your computer's dotfiles
Use option 2 to update your computer's dotfiles with what is in this repo (Be careful when doing this!)

# DO NOT RUN THIS USING SUDO / SU AS THIS WILL REPLACE FILES IN /root IF USING ~ AND YOU SHOULD PROBABLY NOT USE THIS TO MANAGE ROOT PROTECTED FILES

## Why Rust ?

Because I'm learning it. No other reason. Yes `bash` would have been enough, yes I would have been faster with `node`.

## License

Feel free to use this as much as you like, modify edit, publish it, as long as you don't make me responsible for your system breaks if you mess up something using this scripts.
