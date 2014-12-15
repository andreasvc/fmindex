#ifndef FMINDEX_H
#define FMINDEX_H

#include <string>
#include <sdsl/vectors.hpp>
#include <sdsl/suffix_arrays.hpp>

using namespace std;
using namespace sdsl;

typedef csa_wt<wt_huff<rrr_vector<127> >, 512, 1024> fm_index_char;
typedef csa_wt<wt_int<rrr_vector<127> > > fm_index_word;

// word-based index
void makeindex(vector<int> data, string index_file);
int querycounts(string index_file, vector<vector<int> > queries,
		vector<int> &result);
int queryindices(string index_file, vector<vector<int> > queries,
		vector<vector<int>> &result);

// character-based index
void makeindex_char(string filename, string index_file);
int querycounts_char(string index_file, vector<string> queries,
		vector<int> &result);
int queryindices_char(string index_file, vector<string> queries,
		vector<vector<int>> &result);

#endif  /* FMINDEX_H */
