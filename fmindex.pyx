"""FM-Index; a compressed suffix array for fast substring queries.

Converts space-separated tokens to integer indices."""

from array import array
from tempfile import NamedTemporaryFile

cdef class Corpus:
	def __init__(self):
		self.token2id = {None: 0, '_UNK': 1, '_START': 2}
		self.id2token = [None, '_UNK', '_START']
		self.tmpfiles = []

	def addfile(self, filename):
		cdef vector[int] vec
		# encode texts as int arrays
		for line in open(filename):
			vec.push_back(2)
			for token in line.split():
				if token not in self.token2id:
					self.token2id[token] = len(self.token2id)
					self.id2token.append(token)
				vec.push_back(self.token2id[token])
		# index texts
		tmp = NamedTemporaryFile()
		self.tmpfiles.append((filename, tmp))
		makeindex(vec, tmp.name)

	def query(self, list queries, bint indices=False, int limit=0):
		"""Perform a series of queries on each file and return counts.

		:param queries: a list of strings.
		:param indices: if True, return lists of indices instead of counts.
		:return: a dictionary of dictionaries, e.g.:
			{'file1': {'query1': 23, 'query2': 45}, ...}
		"""
		cdef vector[vector[int]] queryvec
		cdef vector[vector[int]] resindices
		cdef vector[int] rescounts
		cdef vector[int] vec
		cdef dict result = {filename: {} for filename, _ in self.tmpfiles}
		for query in queries:
			vec = [self.token2id.get(token, 1) for token in query.split()]
			queryvec.push_back(vec)
		for filename, tmp in self.tmpfiles:
			if indices:
				raise NotImplementedError
				if queryindices(tmp.name, queryvec, resindices) != 0:
					raise ValueError('error loading index %s %s' % (
							filename, tmp.name))
				for query, vec in zip(queries, resindices):
					result[filename][query] = list(vec)
				resindices.clear()
			else:
				if querycounts(tmp.name, queryvec, rescounts) != 0:
					raise ValueError('error loading index %s %s' % (
							filename, tmp.name))
				for query, cnt in zip(queries, rescounts):
					result[filename][query] = cnt
				rescounts.clear()
		return result
