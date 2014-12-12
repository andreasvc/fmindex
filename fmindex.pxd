from cpython.array cimport array
from libcpp.vector cimport vector
from libcpp.string cimport string

cdef extern from "_fmindex.hpp":
	ctypedef void *fm_index_type
	cdef void makeindex(vector[int] data, string filename)
	cdef int querycounts(string index_file, vector[vector[int]] queries,
			vector[int] &result)
	cdef int queryindices(string index_file,
			vector[vector[int]] queries,
			vector[vector[int]] &result)


cdef class Corpus:
	cdef dict token2id
	cdef list id2token
	cdef list tmpfiles
