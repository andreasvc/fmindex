"""FM-Index; a compressed suffix array for fast substring queries.

WordIndex: converts space-separated tokens to integer indices.
CharIndex: provides full text search."""

cimport _fmindex

cdef class WordIndex:
	def __cinit__(self):
		self._ptr = NULL

	def __init__(self, files, encoding='utf8'):
		self.files = files
		self.encoding = encoding
		self._ptr = new _fmindex.WordIndex(files)

	def __dealloc__(self):
		if self._ptr != NULL:
			del self._ptr

	def count(self, list queries):
		"""Perform a series of queries on each file and return counts.

		:param queries: a list of strings.
		:returns: a dictionary of dictionaries, e.g.:
			{'file1': {'query1': 23, 'query2': 45}, ...}
		"""
		cdef vector[vector[int]] result
		self._ptr.count(
				[query.encode(self.encoding).split() for query in queries],
				result)
		return {filename:
				{query: cnt for query, cnt in zip(queries, b)}
				for filename, b in zip(self.files, result)}

	def locate(self, list queries):
		"""Perform a series of queries on each file and return line numbers.

		:param queries: a list of strings.
		:returns: lists of 0-based sentence indices (line numbers), in the form
			of a dictionary of dictionaries with lists, e.g.:
			{'file1': {'query1': [1, 4], 'query2': [2, 7, 9]}, ...}
		"""
		cdef vector[vector[vector[int]]] result
		self._ptr.locate(
				[query.encode(self.encoding).split() for query in queries],
				result)
		return {filename:
				{query: indices for query, indices in zip(queries, b)}
				for filename, b in zip(self.files, result)}

	def extract(self, filename, int sentno):
		"""Extract a sentence from the index.

		:param filename: one of the filenames as passed to __init__().
		:param sentno: a 0-based sentence index.
		:returns: the requested line.
		"""
		cdef int fileno = self.files.index(filename)
		result = self._ptr.extract(fileno, sentno)
		return bytes(result).decode(self.encoding)


cdef class CharIndex:
	def __cinit__(self):
		self._ptr = NULL

	def __init__(self, files, encoding='utf8'):
		self.files = files
		self.encoding = encoding
		self._ptr = new _fmindex.CharIndex(files)

	def __dealloc__(self):
		if self._ptr != NULL:
			del self._ptr

	def count(self, list queries):
		"""Perform a series of queries on each file and return counts.

		:param queries: a list of strings.
		:returns: a dictionary of dictionaries, e.g.:
			{'file1': {'query1': 23, 'query2': 45}, ...}
		"""
		cdef vector[vector[int]] result
		self._ptr.count(
				[query.encode(self.encoding) for query in queries], result)
		return {filename:
				{query: count for query, count in zip(queries, b)}
				for filename, b in zip(self.files, result)}

	def locate(self, list queries):
		"""Perform a series of queries on each file and return line numbers.

		:param queries: a list of strings.
		:returns: lists of 0-based sentence indices (line numbers), in the form
			of a dictionary of dictionaries with lists, e.g.:
			{'file1': {'query1': [1, 4], 'query2': [2, 7, 9]}, ...}
		"""
		cdef vector[vector[vector[int]]] result
		self._ptr.locate(
				[query.encode(self.encoding) for query in queries], result)
		return {filename:
				{query: indices for query, indices in zip(queries, b)}
				for filename, b in zip(self.files, result)}

	def extract(self, filename, int sentno):
		"""Extract a sentence from the index.

		:param filename: one of the filenames as passed to __init__().
		:param sentno: a 0-based sentence index.
		:returns: the requested line.
		"""
		cdef int fileno = self.files.index(filename)
		result = self._ptr.extract(fileno, sentno)
		return bytes(result).decode(self.encoding)


__all__ = ['WordIndex', 'CharIndex']
