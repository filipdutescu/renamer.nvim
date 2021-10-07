[![Actions Status](https://github.com/filipdutescu/renamer.nvim/actions/workflows/ci.yaml/badge.svg)](https://github.com/filipdutescu/renamer.nvim/actions/workflows/ci.yaml)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/filipdutescu/renamer.nvim)](https://github.com/filipdutescu/renamer.nvim/releases)

# renamer.nvim

`renamer.nvim` is a Visual-Studio-Code-like renaming UI for Neovim, writen in
Lua. It is considerably customizable and uses the [Neovim >= 0.5.0](https://github.com/neovim/neovim/releases/tag/v0.5.0)
LSP feature as its backend.

## Features

* **Lightweight:** the overhead of this plugin is insignificant and it makes use
of existent features or plugins you most likely already have installed (only
[plenary.nvim](https://github.com/nvim-lua/plenary.nvim) required).
* **Responsive UI:** takes into account the cursor position and where the popup
will be place relative to the current window to adjust the its placement.
* **[Neovim >= 0.5.0](https://github.com/neovim/neovim/releases/tag/v0.5.0) LSP**:
uses the Neovim LSP to rename across scopes and project.
* **Popup customization**: provides several ways to integrate the popup with
your specific setup, from border characters and title to its colours.

## Getting started

In order to start using `renamer.nvim` you will need to follow the following
sections. If you already meet certain requirements (such as already having
[plenary.nvim](https://github.com/nvim-lua/plenary.nvim)), then you only need to
install `renamer.nvim`.

### Prerequisites

To use `renamer.nvim`, since it makes use of
[Neovim](https://github.com/neovim/neovim)'s built-in LSP, you will need to have
installed [Neovim v0.5.0](https://github.com/neovim/neovim/releases/tag/v0.5.0)
or [newer](https://github.com/neovim/neovim/releases/latest).

### Installation

Using [vim-plug](https://github.com/junegunn/vim-plug):

```viml
Plug 'nvim-lua/plenary.nvim'
Plug 'filipdutescu/renamer.nvim', { 'branch': 'master' }
```

Using [dein](https://github.com/Shougo/dein.vim)

```viml
call dein#add('nvim-lua/plenary.nvim')
call dein#add('filipdutescu/renamer.nvim', { 'rev': 'master' })
```
Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'filipdutescu/renamer.nvim', branch = 'master'
  requires = { {'nvim-lua/plenary.nvim'} }
}
```

After following the steps above, either continue reading below or run `:help
renamer` to get an understanding of the next steps required to use `renamer.nvim`
and how to configure it.

## Usage

TODO

## Customization

TODO

## Default mappings

TODO

## Autocmds

TODO

## Media

TODO

## Contributing

TODO

## License

This project is licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0) - see the [LICENSE](LICENSE) file for details

