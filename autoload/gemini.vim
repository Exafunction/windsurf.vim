function! gemini#GetCompletions(data, ...) abort
  let api_key = gemini#command#ApiKey()
  if empty(api_key)
    return
  endif

  let uri = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent'
  let prompt = a:data.document.text

  let request_body = {
        \ 'contents': [
        \   {
        \     'parts': [
        \       {
        \         'text': prompt
        \       }
        \     ]
        \   }
        \ ]
        \ }

  let data = json_encode(request_body)

  let args = [
        \ 'curl', '-L', uri,
        \ '--header', 'Content-Type: application/json',
        \ '--header', 'x-goog-api-key: ' . api_key,
        \ '-d@-'
        \ ]

  let result = {'out': [], 'err': []}
  let ExitCallback = a:0 && !empty(a:1) ? a:1 : function('s:NoopCallback')
  if has('nvim')
    let jobid = jobstart(args, {
                \ 'on_stdout': { channel, data, t -> add(result.out, join(data, "\n")) },
                \ 'on_stderr': { channel, data, t -> add(result.err, join(data, "\n")) },
                \ 'on_exit': { job, status, t -> ExitCallback(result.out, result.err, status) },
                \ })
    call chansend(jobid, data)
    call chanclose(jobid, 'stdin')
    return jobid
  else
    let job = job_start(args, {
                \ 'in_mode': 'raw',
                \ 'out_mode': 'raw',
                \ 'out_cb': { channel, data -> add(result.out, data) },
                \ 'err_cb': { channel, data -> add(result.err, data) },
                \ 'exit_cb': { job, status -> s:OnExit(result, status, ExitCallback) },
                \ 'close_cb': { channel -> s:OnClose(result, ExitCallback) }
                \ })
    let channel = job_getchannel(job)
    call ch_sendraw(channel, data)
    call ch_close_in(channel)
    return job
  endif
endfunction

function! s:OnExit(result, status, on_complete_cb) abort
  let did_close = has_key(a:result, 'closed')
  if did_close
    call remove(a:result, 'closed')
    call a:on_complete_cb(a:result.out, a:result.err, a:status)
  else
    " Wait until we receive OnClose, and call on_complete_cb then.
    let a:result.exit_status = a:status
  endif
endfunction

function! s:OnClose(result, on_complete_cb) abort
  let did_exit = has_key(a:result, 'exit_status')
  if did_exit
    call a:on_complete_cb(a:result.out, a:result.err, a:result.exit_status)
  else
    " Wait until we receive OnClose, and call on_complete_cb then.
    let a:result.closed = v:true
  endif
endfunction

function! s:NoopCallback(...) abort
endfunction
