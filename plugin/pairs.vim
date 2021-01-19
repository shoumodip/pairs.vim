" Create a new pair
function! pairs#insert(start_char, end_char)

  " Check if the starting character is equal to the ending character
  if a:start_char ==# a:end_char
    " Create a "quotation" mapping as the characters are same

    " First escape the pipes
    let char = substitute(a:start_char, '|', "\\\\|", "g")

    " If the character after the cursor is the ending character, move right.
    " If not, then perform the following steps ---
    " If the character before the cursor is backslash, just insert the character
    " If not, then insert the character pair
    let mapping = "inoremap <buffer> <expr> " . char

    " Escape the double quotes
    let char = substitute(char, '"', '\\"', "g")

    let mapping .= " getline('.')[col('.') - 2] ==# '\\' ? \"" . char . "\""
    let mapping .= " : getline('.')[col('.') - 1] ==# \"" . char
    let mapping .= "\" ? \"\<Right>\" : \"" . char . char . "\<Left>\""

    " Load the mapping
    execute mapping
  else
    " Create a "standard" mapping as the characters are not same

    " First escape the pipes and quotes
    let start_char = substitute(a:start_char, '|', '\\|', "g")
    let start_char = substitute(start_char, '"', '""', "g")
    let end_char = substitute(a:end_char, '"', '""', "g")
    let end_char = substitute(end_char, '|', '\\|', "g")

    " The mapping for inserting the pair ---
    " If the character before the cursor is a backslash, just insert
    " the starting character
    " If not then insert the full pair
    let insert_mapping = "inoremap <buffer> <expr> " . start_char
    let insert_mapping .= " getline('.')[col('.') - 2] !=# '\\'"
    let insert_mapping .= " ? \"" . start_char . end_char . "<Left>\" : \"" . start_char . "\""

    " The mapping for traversing the pair ---
    " If the character before the cursor is a backslash, just insert
    " the ending character
    " If the character before it is the starting character of the pair,
    " go right a character
    " If all these conditions are false, just insert the ending character
    let traverse_mapping = "inoremap <buffer> <expr> " . a:end_char
    let traverse_mapping .= " getline('.')[col('.') - 2] !=# '\\' &&"
    let traverse_mapping .= " getline('.')[col('.') - 1] ==# \"" . a:end_char
    let traverse_mapping .= "\" ? \"<Right>\" : \"" . a:end_char . "\""

    " Load the mappings
    execute insert_mapping
    execute traverse_mapping
  endif
  return ""
endfunction

" The mapping for removing pairs by pressing Backspace
function! pairs#remove()

  " The list of pairs
  let pairs = join(g:auto_pairs, "\n")
  let pairs .= exists("b:auto_pairs") ? "\n" . join(b:auto_pairs, "\n") : ""
  let pairs = trim(pairs)

  " Create the regex for matching the pair
  let pairs = substitute(pairs, '[\[\]]', '\\&', "g")
  let pairs = substitute(pairs, "'", "''", "g")
  let pairs = substitute(pairs, "|", "\\\\|", "g")
  let pairs = substitute(pairs, '*', '\\*', "g")
  let pairs = substitute(pairs, '\n', '\\\\|', "g")

  " If the pairs match up and the character before the pair is not backslash,
  " remove the entire pair, else just do what normal Backspace does
  let mapping = "inoremap <buffer> <expr> <BS> "
  let mapping .= "strpart(getline('.'), col('.') - 2, 2) =~? '\\(" . pairs . "\\)'"
  let mapping .= " && strpart(getline('.'), col('.') - 3, 2) !~# '\\'"
  let mapping .= ' ? "<BS><Del>" : "<BS>"'

  " Load the mapping
  execute mapping
  return ""
endfunction

" Expand the mapping on pressing Enter
function! pairs#expand()

  " The list of pairs
  let pairs = join(g:expand_pairs, "\n")
  let pairs .= exists("b:expand_pairs") ? "\n" . join(b:expand_pairs, "\n") : ""
  let pairs = trim(pairs)

  " Create the regex for matching the pair
  let pairs = substitute(pairs, '[\[\]]', '\\&', "g")
  let pairs = substitute(pairs, "'", "''", "g")
  let pairs = substitute(pairs, "|", "\\\\|", "g")
  let pairs = substitute(pairs, '*', '\\*', "g")
  let pairs = substitute(pairs, '\n', '\\\\|', "g")

  " If the pairs match up and the character before the pair is not backslash,
  " expand the pair, else just do what normal Enter does

  " Example --
  "
  " <html>|</html> <!-- Here the '|' character represents the cursor -->
  "
  " On pressing Enter...
  "
  " <html>
  "   |
  " </html>
  let mapping = "inoremap <buffer> <expr> <CR> "
  let mapping .= "strpart(getline('.'), col('.') - 2, 2) =~? '\\(" . pairs . "\\)'"
  let mapping .= " && strpart(getline('.'), col('.') - 3, 2) !~# '\\'"
  let mapping .= ' ? "<CR><Esc>Oa<Esc>j==kA<BS>" : "<CR>"'

  " Load the mapping
  execute mapping
  return ""
endfunction

" Generate the pairs for the buffer
" When no arguments are supplied or the argument supplied is not 0
" then only load the pairs if the buffer is not present in the list
" of buffers where the pairs have been loaded
" If a non-zero argument is supplied, then load the pairs without
" checking whether pairs have been loaded in the buffer or not
function! pairs#generate(...)

  " The full path to the current buffer
  let buffer_name = fnamemodify(bufname("%"), ":p")

  " Check if pairs have been loaded in the buffer
  if index(g:buffers_pairs_loaded, buffer_name) == -1
    call add(g:buffers_pairs_loaded, buffer_name)
  else

    " If pairs have been generated for the buffer and the argument
    " is not supplied or is 0, then don't generate pairs
    if !exists("a:0") || a:0 == 0
      return ""
    endif
  endif

  " Create the list of pairs
  let pairs = join(g:auto_pairs, "\n")
  let pairs .= exists("b:auto_pairs") ? "\n" . join(b:auto_pairs, "\n") : ""
  let pairs = split(trim(pairs), "\n")

  " Generate the pairs
  for pair in pairs

    " Check if it is a valid pair
    if strlen(pair) != 2
      echoerr "Expected a pair of two characters but received " . pair
      return ""
    endif

    " let start_char = substitute(pair[0], '|', '<Bar>', "g")
    " let end_char = substitute(pair[1], '|', '<Bar>', "g")

    call pairs#insert(pair[0], pair[1])
    " call pairs#insert(start_char, end_char)
  endfor

  " Create mappings for removing pairs and expanding pairs
  call pairs#remove()
  call pairs#expand()

  return ""
endfunction

" Remove the buffer from the pairs list so that when later
" loaded, the pairs will be generated again
function! pairs#buffer_unload()

  " The full path and pairs index to the removed buffer
  let buffer_name = fnamemodify(expand("<afile>"), ":p")
  let buffer_index = index(g:buffers_pairs_loaded, buffer_name)

  " Check if pairs have been loaded in the buffer
  if buffer_index != -1
    call remove(g:buffers_pairs_loaded, buffer_index)
  endif

  return ""
endfunction

" Basic autocommands for pairs
augroup auto_pairs
  autocmd BufEnter * call pairs#generate()
  autocmd BufUnload * call pairs#buffer_unload()

  autocmd FileType html let b:auto_pairs = ["<>"]
  autocmd FileType html let b:expand_pairs = ["><"]

  autocmd FileType sh let b:expand_pairs = ["()"]

  autocmd FileType help let b:auto_pairs = ["||", "**"]

  autocmd FileType markdown let b:expand_pairs = ["``"]
augroup end

let g:auto_pairs = ['()', '{}', '[]', '""', "''", '``']
let g:expand_pairs = ['{}']
let g:buffers_pairs_loaded = []

let b:auto_pairs = []
let b:expand_pairs = []
