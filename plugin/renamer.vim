if !has('nvim-0.5')
    echoerr 'Renamer.nvim requires at least neovim-0.5 to work. Please update or uninstall.'
    finish
endif

if exists('g:loaded_renamer')
    finish
endif
let g:loaded_renamer = 1

hi default link RenamerNormal Normal
hi default link RenamerBorder RenamerNormal
hi default link RenamerTitle Identifier
hi default link RenamerPrefix Identifier

