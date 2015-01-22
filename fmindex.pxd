from libcpp.vector cimport vector
from libcpp.string cimport string
cimport _fmindex

cdef class WordIndex:
	cdef list files
	cdef _fmindex.WordIndex *_ptr

cdef class CharIndex:
	cdef list files
	cdef _fmindex.CharIndex *_ptr
