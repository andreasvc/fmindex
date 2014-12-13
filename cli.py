"""FM-Index.

Usage: %s [--indices] QUERYFILE FILE1...
"""
from __future__ import print_function
import sys
import pandas
import fmindex

if len(sys.argv) < 3:
	print(__doc__ % sys.argv[0])
	sys.exit(1)
indices = '--indices' in sys.argv
if indices:
	sys.argv.remove('--indices')
	c = fmindex.Corpus(sys.argv[2:])
	queries = open(sys.argv[1]).read().splitlines()
	result = c.indices(queries)
	for query in queries:
		print(query)
		for filename in sys.argv[2:]:
			print('%s: %r' % (filename, result[filename][query]))
		print()
else:
	c = fmindex.Corpus(sys.argv[2:])
	queries = open(sys.argv[1]).read().splitlines()
	result = pandas.DataFrame(c.counts(queries),
			index=queries,
			columns=sys.argv[2:]).T
	result.to_csv(sys.stdout)
