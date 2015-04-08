function! FindFile()
	let cn = col('.')
	normal yi'
	exe 'normal' cn.'|'
	let relativePath = @
	if relativePath =~ '^\.'
		let dir = expand('%:p:h')
		let filename = dir.'/'.relativePath
	else
		let filename = 'aweqwe'
	endif
	return filename.'.js'
endfunction

function! Navigate()
	let filename = FindFile()
	exe 'edit ' filename
endfunction

map <c-r> :call Navigate()<cr>
