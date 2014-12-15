from libcpp.vector cimport vector
from libcpp.string cimport string

cdef extern from "_fmindex.hpp":
	cdef void makeindex(vector[int] data, string index_file)
	cdef int querycounts(string index_file, vector[vector[int]] queries,
			vector[int] &result)
	cdef int queryindices(string index_file,
			vector[vector[int]] queries,
			vector[vector[int]] &result)

	cdef void makeindex_char(string filename, string index_file)
	cdef int querycounts_char(string index_file, vector[string] queries,
			vector[int] &result)
	cdef int queryindices_char(string index_file,
			vector[string] queries,
			vector[vector[int]] &result)


cdef class WordIndex:
	cdef dict token2id
	cdef list id2token
	cdef list tmpfiles
	cdef list sentidx

cdef class CharIndex:
	cdef list tmpfiles
	cdef list sentidx
