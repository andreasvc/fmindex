"""FM-Index.

Usage: %s [--indices] [--fts] QUERYFILE FILE1...
"""
from __future__ import print_function
import sys
import pandas
import fmindex

if len(sys.argv) < 3:
	print(__doc__ % sys.argv[0])
	sys.exit(1)
char = '--fts' in sys.argv
indices = '--indices' in sys.argv
if indices:
	sys.argv.remove('--indices')

if char:
	sys.argv.remove('--fts')
	c = fmindex.CharIndex(sys.argv[2:])
else:
	c = fmindex.WordIndex(sys.argv[2:])

if indices:
	queries = open(sys.argv[1]).read().splitlines()
	result = c.locate(queries)
	for query in queries:
		print(query)
		for filename in sys.argv[2:]:
			print('%s: %r' % (filename, result[filename][query]))
		print()
else:
	queries = open(sys.argv[1]).read().splitlines()
	result = pandas.DataFrame(c.count(queries),
			index=queries,
			columns=sys.argv[2:]).T
	result.to_csv(sys.stdout)
