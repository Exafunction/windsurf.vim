# Gemini.vim

_Free, ultrafast Copilot alternative for Vim and Neovim_

Gemini autocompletes your code with AI in all major IDEs. We [launched](https://www.windsurf.com/blog/codeium-copilot-alternative-in-vim) this implementation of the Gemini plugin for Vim and Neovim to bring this modern coding superpower to more developers. Check out our [playground](https://www.windsurf.com/playground) if you want to quickly try out Gemini online.

Contributions are welcome! Feel free to submit pull requests and issues related to the plugin.

<br />

![Example](https://user-images.githubusercontent.com/1908017/213154744-984b73de-9873-4b85-998f-799d92b28eec.gif)

<br />

## 🚀 Getting started

1. Install [Vim](https://github.com/vim/vim) (at least 9.0.0185) or [Neovim](https://github.com/neovim/neovim/releases/latest) (at
   least 0.6)

2. Install `Exafunction/gemini.vim` using your vim plugin manager of
   choice, or manually. See [Installation Options](#-installation-options) below.

3. Run `:Gemini Auth` to set up the plugin and start using Gemini.

You can run `:help gemini` for a full list of commands and configuration
options, or see [this guide](https://www.gemini.com/vim_tutorial) for a quick tutorial on how to use Gemini.

## 🛠️ Configuration

For a full list of configuration options you can run `:help gemini`.
A few of the most popular options are highlighted below.

### ⌨️ Keybindings

Gemini provides the following functions to control suggestions:

| Action                       | Function                       | Default Binding |
| ---------------------------  | ------------------------------ | --------------- |
| Clear current suggestion     | `gemini#Clear()`              | `<C-]>`         |
| Next suggestion              | `gemini#CycleCompletions(1)`  | `<M-]>`         |
| Previous suggestion          | `gemini#CycleCompletions(-1)` | `<M-[>`         |
| Insert suggestion            | `gemini#Accept()`             | `<Tab>`         |
| Manually trigger suggestion  | `gemini#Complete()`           | `<M-Bslash>`    |
| Accept word from suggestion  | `gemini#AcceptNextWord()`     | `<C-k>`         |
| Accept line from suggestion  | `gemini#AcceptNextLine()`     | `<C-l>`         |

Gemini's default keybindings can be disabled by setting

```vim
let g:gemini_disable_bindings = 1
```

or in Neovim:

```lua
vim.g.gemini_disable_bindings = 1
```

If you'd like to just disable the `<Tab>` binding, you can alternatively
use the `g:gemini_no_map_tab` option.

If you'd like to bind the actions above to different keys, this might look something like the following in Vim:

```vim
imap <script><silent><nowait><expr> <C-g> gemini#Accept()
imap <script><silent><nowait><expr> <C-h> gemini#AcceptNextWord()
imap <script><silent><nowait><expr> <C-j> gemini#AcceptNextLine()
imap <C-;>   <Cmd>call gemini#CycleCompletions(1)<CR>
imap <C-,>   <Cmd>call gemini#CycleCompletions(-1)<CR>
imap <C-x>   <Cmd>call gemini#Clear()<CR>
```

Or in Neovim (using [wbthomason/packer.nvim](https://github.com/wbthomason/packer.nvim#specifying-plugins) or [folke/lazy.nvim](https://github.com/folke/lazy.nvim)):

```lua
-- Remove the `use` here if you're using folke/lazy.nvim.
use {
  'Exafunction/gemini.vim',
  config = function ()
    -- Change '<C-g>' here to any keycode you like.
    vim.keymap.set('i', '<C-g>', function () return vim.fn['gemini#Accept']() end, { expr = true, silent = true })
    vim.keymap.set('i', '<c-;>', function() return vim.fn['gemini#CycleCompletions'](1) end, { expr = true, silent = true })
    vim.keymap.set('i', '<c-,>', function() return vim.fn['gemini#CycleCompletions'](-1) end, { expr = true, silent = true })
    vim.keymap.set('i', '<c-x>', function() return vim.fn['gemini#Clear']() end, { expr = true, silent = true })
  end
}
```

(Make sure that you ran `:Gemini Auth` after installation.)

### ⛔ Disabling Gemini

Gemini can be disabled for particular filetypes by setting the
`g:gemini_filetypes` variable in your vim config file (vimrc/init.vim):

```vim
let g:gemini_filetypes = {
    \ "bash": v:false,
    \ "typescript": v:true,
    \ }
```

Gemini is enabled by default for most filetypes.

You can also _disable_ gemini by default with the `g:gemini_enabled` variable,
and enable it manually per buffer by running `:GeminiEnable`:

```vim
let g:gemini_enabled = v:false
```

or in Neovim:

```lua
vim.g.gemini_enabled = false
```

Or you can disable gemini for _all filetypes_ with the `g:gemini_filetypes_disabled_by_default` variable,
and use the `g:gemini_filetypes` variable to selectively enable gemini for specified filetypes:

```vim
" let g:gemini_enabled = v:true
let g:gemini_filetypes_disabled_by_default = v:true

let g:gemini_filetypes = {
    \ "rust": v:true,
    \ "typescript": v:true,
    \ }
```

If you would like to just disable the automatic triggering of completions:

```vim
let g:gemini_manual = v:true

" You might want to use `CycleOrComplete()` instead of `CycleCompletions(1)`.
" This will make the forward cycling of suggestions also trigger the first
" suggestion manually.
imap <C-;> <Cmd>call gemini#CycleOrComplete()<CR>
```

To disable automatic text rendering of suggestions (the gray text that appears for a suggestion):

```vim
let g:gemini_render = v:false
```

### Show Gemini status in statusline

Gemini status can be generated by calling the `gemini#GetStatusString()` function. In
Neovim, you can use `vim.api.nvim_call_function("gemini#GetStatusString", {})` instead.
It produces a 3 char long string with Gemini status:

- `'3/8'` - third suggestion out of 8
- `'0'` - Gemini returned no suggestions
- `'*'` - waiting for Gemini response

In normal mode, status shows if Gemini is enabled or disabled by showing
`'ON'` or `'OFF'`.

In order to show it in status line add following line to your `.vimrc`:

```set statusline+=\{…\}%3{gemini#GetStatusString()}```

Shorter variant without Gemini logo:

```set statusline+=%3{gemini#GetStatusString()}```

Please check `:help statusline` for further information about building statusline in VIM.

vim-airline supports Gemini out-of-the-box since commit [3854429d](https://github.com/vim-airline/vim-airline/commit/3854429d99c8a2fb555a9837b155f33c957a2202).

### Launching Gemini Chat

Calling the `gemini#Chat()` function or using the `Gemini Chat` command will enable search and indexing in the current project and launch Gemini Chat in a new browser window.

```vim
:call gemini#Chat()
:Gemini Chat
```

The project root is determined by looking in Vim's current working directory for some specific files or directories to be present and goes up to parent directories until one is found.  This list of hints is user-configurable and the default value is:

```let g:gemini_workspace_root_hints = ['.bzr','.git','.hg','.svn','_FOSSIL_','package.json']```

Note that launching chat enables telemetry.

## 💾 Installation Options

### 💤 Lazy

```lua
{
  'Exafunction/gemini.vim',
  event = 'BufEnter'
}
```

### 🔌 vim-plug

```vim
Plug 'Exafunction/gemini.vim', { 'branch': 'main' }
```

### 📦 Vundle

```vim
Plugin 'Exafunction/gemini.vim'
```

### 📦 packer.nvim:

```vim
use 'Exafunction/gemini.vim'
```

### 💪 Manual

#### 🖥️ Vim

Run the following. On windows, you can replace `~/.vim` with
`$HOME/vimfiles`:

```bash
git clone https://github.com/Exafunction/gemini.vim ~/.vim/pack/Exafunction/start/gemini.vim
```

#### 💻 Neovim

Run the following. On windows, you can replace `~/.config` with
`$HOME/AppData/Local`:

```bash
git clone https://github.com/Exafunction/gemini.vim ~/.config/nvim/pack/Exafunction/start/gemini.vim
```
