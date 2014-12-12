"""FM-Index.

Usage: %s QUERYFILE FILE1...
"""
import sys
import pandas
import fmindex

if len(sys.argv) < 3:
	print(__doc__ % sys.argv[0])
	sys.exit(1)

c = fmindex.Corpus()
for filename in sys.argv[2:]:
	c.addfile(filename)
queries = open(sys.argv[1]).read().splitlines()
result = pandas.DataFrame(c.query(queries),
		index=queries,
		columns=sys.argv[2:]).T
for a, b in zip(sys.argv[2:], result.sum(axis=1)):
	print('%s:%d' % (a, b))
