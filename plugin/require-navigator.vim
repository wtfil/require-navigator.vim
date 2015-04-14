function! RunNode(code)
	let output = system('node -e "'.a:code.'" 2>/dev/null')
	return substitute(output, '\n', '', '')
endfunction

function! ResolvePackage(name)
	let dir = expand('%:p:h')
	while len(dir) > 1
		let nodedir = dir.'/node_modules/'.a:name
		let package = nodedir.'/package.json'
		if filereadable(package)
			let js = 'console.log(require(\"'.package.'\").main || \"\")'
			let main = RunNode(js)
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

function! ResolveForBrowser(name)
	let sp = split(a:name, '/')
	let alias = sp[0]
	let dir = expand('%:p:h')
	while len(dir) > 1
		let package = dir.'/package.json'
		if filereadable(package)
			let js = 'var package = require(\"'.package.'\"); var aliases = package.browser || package.aliasify && package.aliasify.aliases; console.log(aliases && (aliases[\"'.alias.'\"] || aliases[\"'.alias.'.js\"])|| \"\")'
			let main = RunNode(js)
			if len(main)
				if len(sp) > 1
					let main = dir.'/'.main.'/'.join(sp[1:-1], '/')
				else
					let main = dir.'/'.main
				endif
			endif
			if filereadable(main.'.js')
				return main.'.js'
			elseif filereadable(main.'/index.js')
				return main.'/index.js'
			else
				return main
			endif
		endif
		let dir = '/'.join(split(dir, '/')[0:-2], '/')
	endwhile
	echo 'require-navigator: Can not find module "'.a:name.'"'
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
	let filename = ResolvePackage(relativepath)
	if len(filename)
		return filename
	endif
	return ResolveForBrowser(relativepath)
endfunction

let g:filehistory = []

function! Navigate()
	let filename = FindFile()
	echo filename
	if len(filename)
		let g:filehistory = g:filehistory + [[expand('%:p'), line(".")]]
		exe 'edit ' filename
	endif
endfunction

function! Back()
	if len(g:filehistory)
		let last = g:filehistory[-1]
		let g:filehistory = g:filehistory[0:-2]
		exe 'edit +'.last[1] last[0]
	endif
endfunction

map <c-e> :call Navigate()<cr>
map <c-u> :call Back()<cr>
