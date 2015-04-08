function! ResolvePackage(name)
	let dir = expand('%:p:h')
	while len(dir) > 0
		let nodedir = dir.'/node_modules/'.a:name
		let package = nodedir.'/package.json'
		if filereadable(package)
			let main = system('node -e "console.log(require(\"'.package.'\").main || \"\")"')
			let main = substitute(main, '\n', '', '')

			if len(main)
				let main = nodedir.'/'.main
				if filereadable(main)
					return main
				else
					return main.'/index.js'
				endif

			else
				return nodedir.'/index.js'
			endif
		endif
		let dir = '/'.join(split(dir, '/')[0:-2], '/')
	endwhile
	return ''
endfunction

function! FindFile()
	let cn = col('.')
	normal yi'
	exe 'normal' cn.'|'
	let relativePath = @
	if relativePath =~ '^\.'
		let dir = expand('%:p:h')
		return dir.'/'.relativePath.'.js'
	endif
	return ResolvePackage(relativePath)
endfunction

function! Navigate()
	let filename = FindFile()
	echo filename
	if len(filename)
		exe 'edit ' filename
	endif
endfunction

map <c-r> :call Navigate()<cr>
