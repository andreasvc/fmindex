#include <string>
#include <iomanip>
#include <iostream>
#include <fstream>
#include <sstream>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <algorithm>
#include <unordered_map>
#include <sdsl/vectors.hpp>
#include "_fmindex.hpp"

using namespace std;

#define LINE 1
#define UNK 2


int filesize(string filename) {
	struct stat filestatus;
	stat(filename.c_str(), &filestatus);

	return filestatus.st_size;
}


WordIndex::WordIndex(vector<string> filenames) {
	index.resize(filenames.size());
	lineindex.resize(filenames.size());
	lineindex_rank.resize(filenames.size());
	lineindex_select.resize(filenames.size());

	mapping[""] = 0;
	mapping["\n"] = LINE;
	mapping["_UNK"] = UNK;

	for (size_t i = 0; i < filenames.size(); i++) {
		sdsl::int_vector<> data(8096);
		sdsl::bit_vector bv(8096, 0);
		string line, token;
		size_t sentcnt = 0;
		size_t numtokens = 0;
		ifstream is(filenames[i]);

		while (getline(is, line)) {
			istringstream linestream(line);
			while (linestream >> token) {
				if (numtokens == data.size()) {
					data.resize(2 * data.size());
					bv.resize(2 * bv.size());
				}
				// add token
				auto search = mapping.find(token);
				if (search == mapping.end()) {
					data[numtokens] = mapping.size();
					mapping[token] = mapping.size();
				} else {
					data[numtokens] = search->second;
				}
				bv[numtokens] = 0;
				numtokens++;
			}
			// add end of line marker
			if (numtokens == data.size()) {
				data.resize(2 * data.size());
				bv.resize(2 * bv.size());
			}
			data[numtokens] = LINE;
			bv[numtokens] = 1;
			numtokens++;
			sentcnt++;
		}

		data.resize(numtokens);
		bv.resize(numtokens);

		lineindex[i] = sdsl::sd_vector<>(bv);
		lineindex_rank[i] = sd_vector<>::rank_1_type(&(lineindex[i]));
		lineindex_select[i] = sd_vector<>::select_1_type(&(lineindex[i]));

		// create suffix tree from int_vector
		sdsl::construct_im(index[i], data);

		data.resize(0);
		bv.resize(0);
	}

	revmapping.resize(mapping.size() + 1);  // FIXME why + 1
	for (unordered_map<string, int>::iterator it = mapping.begin();
			it != mapping.end(); ++it)
		revmapping[it->second] = it->first;
}


void WordIndex::mapquery(vector<string> query, vector<int> &result) {
	for (size_t i = 0; i < query.size(); ++i) {
		auto search = mapping.find(query[i]);
		if (search == mapping.end())
			result.push_back(UNK);  // unknown word, not part of mapping
		else
			result.push_back(search->second);
	}
}


int WordIndex::count(
		vector<vector<string> > queries,
		vector<vector<int> > &result) {
	result.resize(index.size());
	for (size_t fileno = 0; fileno < result.size(); ++fileno) {
		result[fileno].resize(queries.size());
		for (size_t i = 0; i < queries.size(); ++i) {
			vector<int> query;
			mapquery(queries[i], query);
			result[fileno][i] = sdsl::count(
					index[fileno], query.begin(), query.end());
		}
	}
	return 0;
}


int WordIndex::locate(
		vector<vector<string> > queries,
		vector<vector<vector<int> > > &result) {
	result.resize(index.size());
	for (size_t fileno = 0; fileno < result.size(); ++fileno) {
		result[fileno].resize(queries.size());
		for (size_t i = 0; i < queries.size(); i++) {
			vector<int> query;
			mapquery(queries[i], query);
			auto locations = sdsl::locate(
					index[fileno], query.begin(), query.end());
			sort(locations.begin(), locations.end());  // FIXME not needed
			for (size_t j = 0; j < locations.size(); ++j) {
				int lineno = lineindex_rank[fileno](locations[j]);
				result[fileno][i].push_back(lineno);
			}
		}
	}
	return 0;
}


string WordIndex::extract(int fileno, int lineno) {
	int begin = lineindex_select[fileno](lineno) + 1;
	int end;
	if (lineno + 1 < (int)lineindex_rank[fileno](index[fileno].size()))
		end = lineindex_select[fileno](lineno + 1) - 1;
	else
		end = index[fileno].size() - 1;

	auto tokens = sdsl::extract(index[fileno], begin, end);

	ostringstream tmp;
	for (size_t i = 0; i < tokens.size(); ++i) {
		if (i != 0)
			tmp << " ";
		tmp << revmapping[tokens[i]];
	}
	return tmp.str();
}


CharIndex::CharIndex(vector<string> filenames) {
	index.resize(filenames.size());
	lineindex.resize(filenames.size());
	lineindex_rank.resize(filenames.size());
	lineindex_select.resize(filenames.size());

	for (size_t i = 0; i < filenames.size(); ++i) {
		sdsl::bit_vector bv(filesize(filenames[i]), 0);
		string line, token;
		size_t numchars = 0;
		ifstream is(filenames[i]);

		// create a bitvector with the locations of line endings in this file
		while (getline(is, line)) {
			numchars += line.size();
			bv[numchars - 1] = 1;
		}

		// create a compressed bitvector mapping token numbers to line numbers
		lineindex[i] = sdsl::sd_vector<>(bv);
		lineindex_rank[i] = sd_vector<>::rank_1_type(&(lineindex[i]));
		lineindex_select[i] = sd_vector<>::select_1_type(&(lineindex[i]));

		// construct index directly from text file
		sdsl::construct(index[i], filenames[i], 1);
		// sdsl::store_to_file(index, index_file);
	}
}


int CharIndex::count(
		vector<string> queries,
		vector<vector<int> > &result) {
	result.resize(index.size());
	for (size_t fileno = 0; fileno < result.size(); ++fileno) {
		result[fileno].resize(queries.size());
		for (size_t i = 0; i < queries.size(); ++i) {
			result[fileno][i] = sdsl::count(
					index[fileno], queries[i].begin(), queries[i].end());
		}
	}
	return 0;
}


int CharIndex::locate(
		vector<string> queries,
		vector<vector<vector<int> > > &result) {
	result.resize(index.size());
	for (size_t fileno = 0; fileno < result.size(); ++fileno) {
		result[fileno].resize(queries.size());
		for (size_t i = 0; i < queries.size(); ++i) {
			auto locations = sdsl::locate(
					index[fileno], queries[i].begin(), queries[i].end());
			sort(locations.begin(), locations.end());  // FIXME not needed
			for (size_t j = 0; j < locations.size(); ++j) {
				int lineno = lineindex_rank[fileno](locations[j]);
				result[fileno][i].push_back(lineno);
			}
		}
	}
	return 0;
}


string CharIndex::extract(int fileno, int lineno) {
	int begin = lineindex_select[fileno](lineno) + 1;
	int end;
	if ((unsigned)lineno + 1 < lineindex_rank[fileno](index[fileno].size()))
		end = lineindex_select[fileno](lineno + 1) - 1;
	else
		end = index[fileno].size() - 1;

	auto tokens = sdsl::extract(index[fileno], begin, end);
	return tokens;
}
