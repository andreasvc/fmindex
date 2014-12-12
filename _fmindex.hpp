#ifndef FMINDEX_H
#define FMINDEX_H

#include <string>
#include <sdsl/vectors.hpp>
#include <sdsl/suffix_arrays.hpp>

using namespace std;
using namespace sdsl;

typedef csa_wt<wt_int<rrr_vector<127> > > fm_index_type;

void makeindex(vector<int> data, string index_file);
int querycounts(string index_file, vector<vector<int>> queries,
		vector<int> &result);
int queryindices(string index_file, vector<vector<int>> queries,
		vector<vector<int>> &result);

#endif  /* FMINDEX_H */
