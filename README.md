[![Build (master)](https://github.com/filipdutescu/renamer.nvim/actions/workflows/ci_master.yaml/badge.svg)](https://github.com/filipdutescu/renamer.nvim/actions/workflows/ci_master.yaml)
[![Build](https://github.com/filipdutescu/renamer.nvim/actions/workflows/ci.yaml/badge.svg)](https://github.com/filipdutescu/renamer.nvim/actions/workflows/ci.yaml)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/filipdutescu/renamer.nvim)](https://github.com/filipdutescu/renamer.nvim/releases)

# renamer.nvim

`renamer.nvim` is a Visual-Studio-Code-like renaming UI for Neovim, writen in
Lua. It is considerably customizable and uses the [Neovim >= 0.5.0](https://github.com/neovim/neovim/releases/tag/v0.5.0)
LSP feature as its backend.

## Table of contents

- [Features](#features)
- [Getting started](#getting-started)
- [Usage](#usage)
- [Customization](#customization)
- [Default mappings](#default-mappings)
- [Media](#media)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Lightweight:** the overhead of this plugin is insignificant and it makes use
  of existent features or plugins you most likely already have installed (only
  [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) required).
- **Responsive UI:** takes into account the cursor position and where the popup
  will be place relative to the current window to adjust the its placement.
- **[Neovim >= 0.5.0](https://github.com/neovim/neovim/releases/tag/v0.5.0) LSP**:
  uses the Neovim LSP to rename across scopes and project.
- **Popup customization**: provides several ways to integrate the popup with
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

### Verify your installation

After those steps, you should be able to run `:checkhealth renamer` in order to
see if anything is missing from your setup.

After following the steps above, either continue reading below or run `:help
renamer` to get an understanding of the next steps required to use `renamer.nvim`
and how to configure it.

## Usage

To rename the current word using `renamer.nvim`, you need to call the `rename`
method (`require('renamer).rename()`).

The recommended way of doing it is by setting up keybindings to call the function:

VimScript:

```viml
inoremap <silent> <F2> <cmd>lua require('renamer').rename()<cr>
nnoremap <silent> <leader>rn <cmd>lua require('renamer').rename()<cr>
vnoremap <silent> <leader>rn <cmd>lua require('renamer').rename()<cr>
```

Lua:

```lua
vim.api.nvim_set_keymap('i', '<F2>', '<cmd>lua require("renamer").rename()<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua require("renamer").rename()<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>rn', '<cmd>lua require("renamer").rename()<cr>', { noremap = true, silent = true })
```

## Customization

`renamer.nvim` offers different customization options, in order to change its
appearance and behaviour. Below you will find the defaults and the structure
of the settings table.

### Renamer setup structure

```lua
require('renamer').setup {
    title = 'Rename',
    padding = { 0, 0, 0, 0 },
    border = true,
    border_chars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    prefix = '',
}
```

Colours can also be changed, in order to better fit your theme or taste. The
following highlight groups can also be modified to theme the popup colours:

```viml
hi default link RenamerNormal Normal
hi default link RenamerBorder RenamerNormal
hi default link RenamerPrefix Identifier
```

## Default mappings

TODO - Should add mappings to make it easy to edit and select text in the prompt.

## Media

TODO - Should add media to showcase the plugin

## Contributing

All contributions are welcome! Just open a pull request or an issue. Please read
[CONTRIBUTING.md](CONTRIBUTING.md).

## License

This project is licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0) - see the
[LICENSE](LICENSE) file for details

