"""FM-Index; a compressed suffix array for fast substring queries.

WordIndex: converts space-separated tokens to integer indices.
CharIndex: provides full text search."""

import sys
cimport _fmindex

cdef class Index:
	def __init__(self, files, encoding='utf8'):
		self.files = files
		self.encoding = encoding

	def count(self, list queries):
		"""Perform a series of queries on each file and return counts.

		:param queries: a list of strings.
		:returns: a dictionary of dictionaries, e.g.:
			{'file1': {'query1': 23, 'query2': 45}, ...}
		"""

	def locate(self, list queries):
		"""Perform a series of queries on each file and return line numbers.

		:param queries: a list of strings.
		:returns: lists of 0-based sentence indices (line numbers), in the form
			of a dictionary of dictionaries with lists, e.g.:
			{'file1': {'query1': [1, 4], 'query2': [2, 7, 9]}, ...}
		"""

	def extract(self, filename, int sentno):
		"""Extract a sentence from the index.

		:param filename: one of the filenames as passed to __init__().
		:param sentno: a 0-based sentence index.
		:returns: the requested line.
		"""

	def countsum(self, list queries):
		"""For each file, perform queries and return sum.

		:param queries: a list of strings.
		:returns: a dictionary of counts, e.g.: {'file1': 23, 'file2': 45, ...}
		"""

	def numlines(self):
		"""Return a list with the number of lines in each file (corresponding
		to the files passed to init)."""

	def numtokens(self):
		"""Return a list with the number of tokens in each file (corresponding
		to the files passed to init)."""


cdef class WordIndex(Index):
	def __cinit__(self):
		self._ptr = NULL

	def __init__(self, files, encoding='utf8'):
		super(WordIndex, self).__init__(files, encoding=encoding)
		self._ptr = new _fmindex.WordIndex([
				filename.encode(sys.getfilesystemencoding())
				for filename in files])

	def __dealloc__(self):
		if self._ptr != NULL:
			del self._ptr

	def count(self, list queries):
		cdef vector[vector[int]] result
		self._ptr.count(
				[query.encode(self.encoding).split() for query in queries],
				result)
		return {filename:
				{query: cnt for query, cnt in zip(queries, b)}
				for filename, b in zip(self.files, result)}

	def locate(self, list queries):
		cdef vector[vector[vector[int]]] result
		self._ptr.locate(
				[query.encode(self.encoding).split() for query in queries],
				result)
		return {filename:
				{query: indices for query, indices in zip(queries, b)}
				for filename, b in zip(self.files, result)}

	def extract(self, filename, int sentno):
		cdef int fileno = self.files.index(filename)
		result = self._ptr.extract(fileno, sentno)
		return bytes(result).decode(self.encoding)

	def countsum(self, list queries):
		cdef vector[int] result
		self._ptr.countsum(
				[query.encode(self.encoding).split() for query in queries],
				result)
		return {filename: cnt for filename, cnt in zip(self.files, result)}

	def numlines(self):
		return [self._ptr.numlines(n) for n, _ in enumerate(self.files)]

	def numtokens(self):
		return [self._ptr.numtokens(n) for n, _ in enumerate(self.files)]


cdef class CharIndex(Index):
	def __cinit__(self):
		self._ptr = NULL

	def __init__(self, files, encoding='utf8'):
		super(CharIndex, self).__init__(files, encoding=encoding)
		self._ptr = new _fmindex.CharIndex([
				filename.encode(sys.getfilesystemencoding())
				for filename in files])

	def __dealloc__(self):
		if self._ptr != NULL:
			del self._ptr

	def count(self, list queries):
		cdef vector[vector[int]] result
		self._ptr.count(
				[query.encode(self.encoding) for query in queries], result)
		return {filename:
				{query: count for query, count in zip(queries, b)}
				for filename, b in zip(self.files, result)}

	def locate(self, list queries):
		cdef vector[vector[vector[int]]] result
		self._ptr.locate(
				[query.encode(self.encoding) for query in queries], result)
		return {filename:
				{query: indices for query, indices in zip(queries, b)}
				for filename, b in zip(self.files, result)}

	def extract(self, filename, int sentno):
		cdef int fileno = self.files.index(filename)
		result = self._ptr.extract(fileno, sentno)
		return bytes(result).decode(self.encoding)

	def countsum(self, list queries):
		cdef vector[int] result
		self._ptr.countsum(
				[query.encode(self.encoding).split() for query in queries],
				result)
		return {filename: cnt for filename, cnt in zip(self.files, result)}

	def numlines(self):
		return [self._ptr.numlines(n) for n, _ in enumerate(self.files)]

	def numtokens(self):
		return [self._ptr.numtokens(n) for n, _ in enumerate(self.files)]


__all__ = ['WordIndex', 'CharIndex']
