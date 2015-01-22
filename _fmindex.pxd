from libcpp.vector cimport vector
from libcpp.string cimport string

cdef extern from "_fmindex.hpp":
	cppclass WordIndex:
		# NB! std::bad_alloc will be converted to MemoryError
		WordIndex(vector[string] filenames) except +

		int count(
				vector[vector[string]] queries,
				vector[vector[int]] &result)
		int locate(
				vector[vector[string]] queries,
				vector[vector[vector[int]]] &result)
		string extract(int fileno, int lineno)

	cppclass CharIndex:
		# NB! std::bad_alloc will be converted to MemoryError
		CharIndex(vector[string] filenames) except +

		int count(
				vector[string] queries,
				vector[vector[int]] &result)
		int locate(
				vector[string] queries,
				vector[vector[vector[int]]] &result)
		string extract(int fileno, int lineno)
