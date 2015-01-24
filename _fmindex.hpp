#ifndef FMINDEX_H
#define FMINDEX_H

#include <string>
#include <sdsl/vectors.hpp>
#include <sdsl/suffix_arrays.hpp>

using namespace std;
using namespace sdsl;

// word-based index
// typedef csa_wt<wt_int<rrr_vector<127> > > fm_index_word;
// typedef csa_wt<wt_huff_int<rrr_vector<63> >, 64, 128 > fm_index_word;
typedef csa_wt<wm_int<rrr_vector<63> >, 64, 128 > fm_index_word;
class WordIndex {
	unordered_map<string, int> mapping;
	vector<string> revmapping;
	vector<fm_index_word> index;
	vector<sd_vector<> > lineindex;
	vector<sd_vector<>::rank_1_type > lineindex_rank;
	vector<sd_vector<>::select_1_type > lineindex_select;

	void mapquery(vector<string> query, vector<int> &result);

	public:
		WordIndex(vector<string> filenames);

		int count(
				vector<vector<string> > queries,
				vector<vector<int> > &result);
		int locate(
				vector<vector<string> > queries,
				vector<vector<vector<int> > > &result);
		string extract(int fileno, int lineno);
		int countsum(
				vector<vector<string> > queries,
				vector<int> &result);
		int numlines(int fileno);
		int numtokens(int fileno);
};


// character-based index
typedef csa_wt<wt_huff<rrr_vector<63> >, 512, 1024> fm_index_char;
class CharIndex {
	vector<fm_index_char> index;
	vector<sd_vector<> > lineindex;
	vector<sd_vector<>::rank_1_type > lineindex_rank;
	vector<sd_vector<>::select_1_type > lineindex_select;

	public:
		CharIndex(vector<string> filenames);

		int count(
				vector<string> queries,
				vector<vector<int> > &result);
		int locate(
				vector<string> queries,
				vector<vector<vector<int> > > &result);
		string extract(int fileno, int lineno);
		int countsum(
				vector<string> queries,
				vector<int> &result);
		int numlines(int fileno);
		int numtokens(int fileno);
};

#endif  /* FMINDEX_H */
