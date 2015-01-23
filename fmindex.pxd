from libcpp.vector cimport vector
from libcpp.string cimport string
cimport _fmindex

cdef class Index:
	cdef list files
	cdef object encoding

cdef class WordIndex(Index):
	cdef _fmindex.WordIndex *_ptr

cdef class CharIndex(Index):
	cdef _fmindex.CharIndex *_ptr
