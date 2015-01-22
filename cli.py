"""FM-Index.

Usage: %s [--indices|--counts] [--fts] QUERYFILE FILE1...
"""
from __future__ import print_function
import sys
import pandas
import fmindex

if len(sys.argv) < 3:
	print(__doc__ % sys.argv[0])
	sys.exit(1)

indices = '--indices' in sys.argv
counts = '--counts' in sys.argv or '-c' in sys.argv
if indices:
	sys.argv.remove('--indices')
if '--counts' in sys.argv:
	sys.argv.remove('--counts')
if '-c' in sys.argv:
	sys.argv.remove('-c')

if '--fts' in sys.argv:
	sys.argv.remove('--fts')
	c = fmindex.CharIndex(sys.argv[2:])
else:
	c = fmindex.WordIndex(sys.argv[2:])

queries = open(sys.argv[1]).read().splitlines()
if indices:
	result = c.locate(queries)
	for query in queries:
		print(query)
		for filename in sys.argv[2:]:
			print('%s: %r' % (filename, result[filename][query]))
		print()
elif counts:
	result = pandas.DataFrame(c.count(queries),
			index=queries,
			columns=sys.argv[2:]).T
	result.to_csv(sys.stdout)
else:  # print line number and matching line
	result = c.locate(queries)
	for query in queries:
		print(query)
		for filename in sys.argv[2:]:
			for n in result[filename][query]:
				print('%s:%d:%s' % (filename, n, c.extract(filename, n)))
		print()
