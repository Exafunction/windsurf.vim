function! gemini#command#BrowserCommand() abort
  if has('win32') && executable('rundll32')
    return 'rundll32 url.dll,FileProtocolHandler'
  elseif isdirectory('/private') && executable('/usr/bin/open')
    return '/usr/bin/open'
  elseif executable('xdg-open')
    return 'xdg-open'
  else
    return ''
  endif
endfunction

function! gemini#command#XdgConfigDir() abort
  let config_dir = $XDG_CONFIG_HOME
  if empty(config_dir)
    let config_dir = $HOME . '/.config'
  endif
  return config_dir . '/gemini'
endfunction

function! gemini#command#HomeDir() abort
  let data_dir = $XDG_DATA_HOME
  if empty(data_dir)
    let data_dir = $HOME . '/.gemini'
  else
    let data_dir = data_dir . '/.gemini'
  endif
  return data_dir
endfunction

function! gemini#command#LoadConfig(dir) abort
  let config_path = a:dir . '/config.json'
  if filereadable(config_path)
    let contents = join(readfile(config_path), '')
    if !empty(contents)
      return json_decode(contents)
    endif
  endif

  return {}
endfunction

let s:api_key = get(gemini#command#LoadConfig(gemini#command#HomeDir()), 'apiKey', '')

let s:commands = {}

function! s:commands.Auth(...) abort
  call inputsave()
  let api_key = inputsecret('Paste your Gemini API key here: ')
  call inputrestore()

  if !empty(api_key)
    let s:api_key = api_key
    let config_dir = gemini#command#HomeDir()
    let config_path = config_dir . '/config.json'
    let config = gemini#command#LoadConfig(config_dir)
    let config.apiKey = api_key

    try
      call mkdir(config_dir, 'p')
      call writefile([json_encode(config)], config_path)
    catch
      call gemini#log#Error('Could not persist api key to config.json')
    endtry
  endif
endfunction

function s:commands.Chat(...) abort
  call gemini#Chat()
endfunction

function! s:commands.Disable(...) abort
  let g:gemini_enabled = 0
endfunction

function! s:commands.DisableBuffer(...) abort
  let b:gemini_enabled = 0
endfunction

" Run gemini server only if its not already started
function! gemini#command#StartLanguageServer() abort
endfunction

function! s:commands.Enable(...) abort
  let g:gemini_enabled = 1
  call gemini#command#StartLanguageServer()
endfunction

function! s:commands.EnableBuffer(...) abort
  let b:gemini_enabled = 1
  call gemini#command#StartLanguageServer()
endfunction

function! s:commands.Toggle(...) abort
  if exists('g:gemini_enabled') && g:gemini_enabled == v:false
      call s:commands.Enable()
  else
      call s:commands.Disable()
  endif
endfunction

function! gemini#command#ApiKey() abort
  if s:api_key == ''
    echom 'Gemini: No API key found; maybe you need to run `:Gemini Auth`?'
  endif
  return s:api_key
endfunction

function! gemini#command#Complete(arg, lead, pos) abort
  let args = matchstr(strpart(a:lead, 0, a:pos), 'G\%[emini][! ] *\zs.*')
  return sort(filter(keys(s:commands), { k -> strpart(k, 0, len(a:arg)) ==# a:arg }))
endfunction

function! gemini#command#Command(arg) abort
  let cmd = matchstr(a:arg, '^\%(\\.\|\S\)\+')
  let arg = matchstr(a:arg, '\s\zs\S.*')
  if !has_key(s:commands, cmd)
    return 'echoerr ' . string("Gemini: command '" . string(cmd) . "' not found")
  endif
  let res = s:commands[cmd](arg)
  if type(res) == v:t_string
    return res
  else
    return ''
  endif
endfunction
