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
result = pandas.DataFrame(c.counts(queries),
		index=queries,
		columns=sys.argv[2:]).T
result.to_csv(sys.stdout)
