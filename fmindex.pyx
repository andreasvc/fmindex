"""FM-Index; a compressed suffix array for fast substring queries.

Converts space-separated tokens to integer indices."""

import re
from bisect import bisect
from tempfile import NamedTemporaryFile

cdef class WordIndex:
	def __init__(self, files=None):
		self.token2id = {None: 0, '_UNK': 1, '_START': 2}
		self.id2token = [None, '_UNK', '_START']
		self.tmpfiles = []
		if files:
			for filename in files:
				self.addfile(filename)

	def addfile(self, filename):
		"""Add a text file and index it."""
		cdef vector[int] vec
		self.sentidx = []
		# encode texts as int arrays
		for line in open(filename):
			vec.push_back(2)
			self.sentidx.append(vec.size())
			for token in line.split():
				if token not in self.token2id:
					self.token2id[token] = len(self.token2id)
					self.id2token.append(token)
				vec.push_back(self.token2id[token])
		# index texts
		tmp = NamedTemporaryFile()
		self.tmpfiles.append((filename, tmp))
		makeindex(vec, tmp.name)

	def count(self, list queries):
		"""Perform a series of queries on each file and return counts.

		:param queries: a list of strings.
		:returns: a dictionary of dictionaries, e.g.:
			{'file1': {'query1': 23, 'query2': 45}, ...}
		"""
		cdef vector[vector[int]] queryvec
		cdef vector[int] rescounts
		cdef vector[int] vec
		cdef dict result = {filename: {} for filename, _ in self.tmpfiles}
		for query in queries:
			vec = [self.token2id.get(token, 1) for token in query.split()]
			queryvec.push_back(vec)
		for filename, tmp in self.tmpfiles:
			if querycounts(tmp.name, queryvec, rescounts) != 0:
				raise ValueError('error loading index %s %s' % (
						filename, tmp.name))
			for query, cnt in zip(queries, rescounts):
				result[filename][query] = cnt
			rescounts.clear()
		return result

	def locate(self, list queries):
		"""Perform a series of queries on each file and return line numbers.

		:param queries: a list of strings.
		:returns: lists of 1-based sentence indices (line numbers), in the form
			of a dictionary of dictionaries with lists, e.g.:
			{'file1': {'query1': [1, 4], 'query2': [2, 7, 9]}, ...}
		"""
		cdef vector[vector[int]] queryvec
		cdef vector[vector[int]] resindices
		cdef vector[int] vec
		cdef dict result = {filename: {} for filename, _ in self.tmpfiles}
		for query in queries:
			vec = [self.token2id.get(token, 1) for token in query.split()]
			queryvec.push_back(vec)
		for filename, tmp in self.tmpfiles:
			resindices.resize(len(queries))
			if queryindices(tmp.name, queryvec, resindices) != 0:
				raise ValueError('error loading index %s %s' % (
						filename, tmp.name))
			for query, vec in zip(queries, resindices):
				result[filename][query] = [
						bisect(self.sentidx, n) for n in sorted(vec)]
			resindices.clear()
		return result



cdef class CharIndex:
	def __init__(self, files=None):
		self.tmpfiles = []
		if files:
			for filename in files:
				self.addfile(filename)

	def addfile(self, filename):
		"""Add a text file and index it."""
		# get index of each line
		self.sentidx = [0] + [match.end() for match in
				re.finditer(r'\n', open(filename).read())]
		# index text
		tmp = NamedTemporaryFile()
		self.tmpfiles.append((filename, tmp))
		makeindex_char(filename, tmp.name)

	def count(self, list queries):
		"""Perform a series of queries on each file and return counts.

		:param queries: a list of strings.
		:returns: a dictionary of dictionaries, e.g.:
			{'file1': {'query1': 23, 'query2': 45}, ...}
		"""
		cdef vector[string] queryvec = queries
		cdef vector[int] rescounts
		cdef dict result = {filename: {} for filename, _ in self.tmpfiles}
		for filename, tmp in self.tmpfiles:
			if querycounts_char(tmp.name, queryvec, rescounts) != 0:
				raise ValueError('error loading index %s %s' % (
						filename, tmp.name))
			for query, cnt in zip(queries, rescounts):
				result[filename][query] = cnt
			rescounts.clear()
		return result

	def locate(self, list queries):
		"""Perform a series of queries on each file and return line numbers.

		:param queries: a list of strings.
		:returns: lists of 1-based sentence indices (line numbers), in the form
			of a dictionary of dictionaries with lists, e.g.:
			{'file1': {'query1': [1, 4], 'query2': [2, 7, 9]}, ...}
		"""
		cdef vector[string] queryvec = queries
		cdef vector[vector[int]] resindices
		cdef vector[int] vec
		cdef dict result = {filename: {} for filename, _ in self.tmpfiles}
		for filename, tmp in self.tmpfiles:
			resindices.resize(len(queries))
			if queryindices_char(tmp.name, queryvec, resindices) != 0:
				raise ValueError('error loading index %s %s' % (
						filename, tmp.name))
			for query, vec in zip(queries, resindices):
				result[filename][query] = [
						bisect(self.sentidx, n) for n in sorted(vec)]
			resindices.clear()
		return result


__all__ = ['Corpus']
