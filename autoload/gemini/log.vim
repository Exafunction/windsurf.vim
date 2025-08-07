if exists('g:loaded_gemini_log')
  finish
endif
let g:loaded_gemini_log = 1

if !exists('s:logfile')
  let s:logfile = expand(get(g:, 'gemini_log_file', tempname() . '-gemini.log'))
  try
    call writefile([], s:logfile)
  catch
  endtry
endif

function! gemini#log#Logfile() abort
  return s:logfile
endfunction

function! gemini#log#Log(level, msg) abort
  let min_level = toupper(get(g:, 'gemini_log_level', 'WARN'))
  " echo "logging to: " . s:logfile . "," . min_level . "," . a:level . "," a:msg
  for level in ['ERROR', 'WARN', 'INFO', 'DEBUG', 'TRACE']
    if level == toupper(a:level)
      try
        if filewritable(s:logfile)
          call writefile(split(a:msg, "\n", 1), s:logfile, 'a')
        endif
      catch
      endtry
    endif
    if level == min_level
      break
    endif
  endfor
endfunction

function! gemini#log#Error(msg) abort
  call gemini#log#Log('ERROR', a:msg)
endfunction

function! gemini#log#Warn(msg) abort
  call gemini#log#Log('WARN', a:msg)
endfunction

function! gemini#log#Info(msg) abort
  call gemini#log#Log('INFO', a:msg)
endfunction

function! gemini#log#Debug(msg) abort
  call gemini#log#Log('DEBUG', a:msg)
endfunction

function! gemini#log#Trace(msg) abort
  call gemini#log#Log('TRACE', a:msg)
endfunction

function! gemini#log#Exception() abort
  if !empty(v:exception)
    call gemini#log#Error('Exception: ' . v:exception . ' [' . v:throwpoint . ']')
  endif
endfunction
