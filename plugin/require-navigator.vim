function! ResolvePackage(name)
	let dir = expand('%:p:h')
	while len(dir) > 1
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
	echo 'require-navigator: Can not find module "'.a:name.'"'
	return ''
endfunction

function! FindFile()
	let cn = col('.')
	normal yi(
	exe 'normal' cn.'|'
	let relativepath = @
	let relativepath = relativepath[1:-2]
	if relativepath =~ '^\.'
		let dir = expand('%:p:h')
		let filename = dir.'/'.relativepath
		echo filename
		if filereadable(filename.'.js')
			return filename.'.js'
		else
			return filename.'/index.js'
		endif
	endif
	return ResolvePackage(relativepath)
endfunction

let g:filehistory = []

function! Navigate()
	let filename = FindFile()
	echo filename
	if len(filename)
		let g:filehistory = g:filehistory + [expand('%:p')]
		exe 'edit ' filename
	endif
endfunction

function! Back()
	if len(g:filehistory)
		let last = g:filehistory[-1]
		let g:filehistory = g:filehistory[0:-2]
		exe 'edit ' last
	endif
endfunction

map <c-r> :call Navigate()<cr>
map <c-u> :call Back()<cr>
