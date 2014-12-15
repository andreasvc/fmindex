FM-Index
========

An `FM-index <http://en.wikipedia.org/wiki/FM-index>`_ is a compressed suffix
array that offers fast substring queries.

This is a Python wrapper around
`sdsl-lite <https://github.com/simongog/sdsl-lite>`_ to provide an FM-Index
to a corpus of text files. This module provides an efficient method of perform
a large number of substring searches.

Both a character-based and a word-based version is available.
The character-based version offers full-text search.
The word-based version converts each space-separated token to an integer
(i.e., words are never matched partially).
This works best for texts which are tokenized, one sentence per line, with
space-separated tokens.

Example
-------
An example application shows how to perform a set of queries from a file
against a number of files::

    python cli.py <queries> <files>

The result is similar to ``grep -c -f queries files``, although the
counts will differ because grep counts multiple matches per line as a single
match.


Installation
------------
requires sdsl::

    git clone https://github.com/andreasvc/sdsl-lite.git
    cd sdsl-lite
    ./install.sh $HOME/.local

and Cython::

    pip install --user cython

To install, run::

    make

References
----------
- http://en.wikipedia.org/wiki/FM-index
- https://github.com/simongog/sdsl-lite
