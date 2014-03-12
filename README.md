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

**From the [ack docs](http://beyondgrep.com/)** (my favorite feature):

    --type=TYPE, --type=noTYPE

        Specify the types of files to include or exclude from a search. TYPE is
        a filetype, like perl or xml. --type=perl can also be specified as
        --perl, and --type=noperl can be done as --noperl.

        If a file is of both type "foo" and "bar", specifying --foo and --nobar
        will exclude the file, because an exclusion takes precedence over an
        inclusion.

        Type specifications can be repeated and are ORed together.

        See ack --help=types for a list of valid types.

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
