# pairs.vim
Automatic pairs in vim

## Workings
Pairs will provide some mappings for pairs.  Let `()` be a pair and **|** be the cursor.

### Complete a pair
Press the first character of a pair

**|** &nbsp;&nbsp;&nbsp;&nbsp;If `(` is pressed, it will result in `(`**|**`)`\
`\`**|** If `(` is pressed, it will result in `\(`**|**

### Remove a pair `<BS>`
`(`**|**`)` &nbsp;&nbsp;If backspace is pressed, it will result in **|**\
`\(`**|**`)` If backspace is pressed, it will result in `\`**|**`)`\
`(`**|** &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If backspace is pressed, it will result in **|**\
`blah`**|** If backspace is pressed, it will result in `bla`**|**

### Expand a pair `<CR>`
Let `<>` be an automatic pair and `><` be a pair that expands.

`<html>`**|**`</html>`

After pressing `<CR>`

`<html>`\
&nbsp;&nbsp;&nbsp;&nbsp;**|**\
`</html>`

## Configuration

- `g:auto_pairs` The global list of pairs which auto-complete. Defaults to
```vim
["()", "{}", "[]", "''", "``", '""']
```

- `g:expand_pairs` The global list of pairs which get expanded. Defaults to
```vim
["{}"]
```

- `b:auto_pairs` The local list of pairs which auto-complete. Examples
```vim
autocmd FileType html let b:auto_pairs = ["<>"]
autocmd FileType help let b:auto_pairs = ["||", "**"]
```

- `b:expand_pairs` The local list of pairs which get expanded. Examples
```vim
autocmd FileType html let b:expand_pairs = ["><"]
autocmd FileType sh let b:expand_pairs = ["()"]
```

## Force

Normally pairs get generated for each buffer **once**. However if you wish to manually re-generate pairs for a buffer, it is totally possible.

- `pairs#generate()` This is the function which generates the pairs for the current buffer. If no arguments are supplied or the argument supplied is `0`, it will not generate pairs for the buffer if the buffer is present in `g:buffers_pairs_loaded`. To force generate the pairs, give it a **non-zero** argument.

```vim
:call pairs#generate(1)
```

## Help
```vim
:h pairs#generate()
:h g:auto_pairs
:h g:expand_pairs
:h b:auto_pairs
:h b:expand_pairs
```

## License
MIT
