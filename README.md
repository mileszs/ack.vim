# ack.vim

This plugin is a front for the Perl module
[App::Ack](http://search.cpan.org/~petdance/ack/ack).  Ack can be used as a
replacement for 99% of the uses of _grep_.  This plugin will allow you to run
ack from vim, and shows the results in a split window.

## Installation

### Ack

You will need the ack, of course, to install it follow the
[manual](http://beyondgrep.com/install/)

### The Plugin

To install it is recommended to use one of the popular package managers for Vim,
rather than installing by drag and drop all required files into your `.vim` folder.

#### Manual (not recommended)

Just
[download](https://github.com/mileszs/ack.vim/archive/kb-improve-readme.zip) the
plugin and put it in your `~/.vim/`(or `%PROGRAMFILES%/Vim/vimfiles` on windows)

#### Vundle

    Bundle 'mileszs/ack.vim'

#### NeoBundle

    NeoBundle 'mileszs/ack.vim'

## Usage

    :Ack [options] {pattern} [{directories}]

Search recursively in {directory} (which defaults to the current directory) for
the {pattern}.

Files containing the search term will be listed in the split window, along with
the line number of the occurrence, once for each occurrence.  [Enter] on a line
in this window will open the file, and place the cursor on the matching line.

Just like where you use :grep, :grepadd, :lgrep, and :lgrepadd, you can use
`:Ack`, `:AckAdd`, `:LAck`, and `:LAckAdd` respectively.
(See `doc/ack.txt`, or install and `:h Ack` for more information.)

For more ack options see
[ack documentation](http://beyondgrep.com/documentation/)

### Keyboard Shortcuts

In the quickfix window, you can use:

    o    to open (same as enter)
    O    to open and close quickfix window
    go   to preview file (open but maintain focus on ack.vim results)
    t    to open in new tab
    T    to open in new tab silently
    h    to open in horizontal split
    H    to open in horizontal split silently
    v    to open in vertical split
    gv   to open in vertical split silently
    q    to close the quickfix window

This Vim plugin is derived (and by derived, I mean copied, essentially) from
Antoine Imbert's blog post
[Ack and Vim Integration](http://blog.ant0ine.com/typepad/2007/03/ack-and-vim-integration.html)
(in particular, the function at the bottom of the post).  I added a help file that
provides just enough reference to get you going.  I also highly recommend you
check out the docs for the Perl script 'ack', for obvious reasons:
[ack - grep-like text finder](http://beyondgrep.com/).

## Using `ag` with ack.vim

Basically you can use [ag](https://github.com/ggreer/the_silver_searcher) with
ack.vim, you just need to do some changes on your setup:

    let g:ackprg = 'ag'
    let g:ack_wildignore = 0

For more information see ack.vim
[documentation](https://github.com/mileszs/ack.vim/blob/master/doc/ack.txt)

## RoadMap

Goals for 1.0:

* Improve documentation, list all options and shortcuts
* Use `autoload` directory to define functions, instead of `plugin`.
* Add a help toggle `?`(like NERDTree)
* Add option to open all files from result list
* Respect wildignore - DONE on master
