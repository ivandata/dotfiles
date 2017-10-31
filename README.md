# Dotfiles
My OS X dotfiles. These are the base dotfiles that I start with when I set up a new environment.

## How to install 
The installation overwrite existing dotfiles in HOME directories. 

(:warning: **DO NOT** run the `setup` snippet if you don't fully
understand [what it does](install.sh). Seriously, **DON'T**!)

To set up the dotfiles just run the appropriate snippet in the terminal:
```bash
bash -c "$(curl -LsS raw.github.com/ivandata/dotfiles/master/install.sh)"
```

The setup process will:

* Download the dotfiles on your computer (by default it will suggest ~/dotfiles/temp)
* Create some additional directories
* Symlink the some .dotfiles
* Install applications & command-line tools for macOS 
* Set custom macOS preferences

## Options
<table>
    <tr>
        <td><code>-h</code>, <code>--help</code></td>
        <td>Help</td>
    </tr>
    <tr>
        <td><code>-up</code>, <code>--update</code></td>
        <td>Update the dotfiles </td>
    </tr>
    <tr>
        <td><code>-l</code>, <code>--list</code></td>
        <td>List of additional applications to install</td>
    </tr>
</table>
