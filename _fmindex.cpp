#include "_fmindex.hpp"

void makeindex(vector<int> data, string index_file) {
	// copy to compressed vector (maybe store in there directly?)
	fm_index_word index;
	int_vector<> data2(data.size());
	for (size_t i=0; i < data.size(); i++)
		if (data[i] == 0)
			cerr << "Zero at " << i << endl;
		else
			data2[i] = data[i];

	// create suffix tree from int_vector
	sdsl::construct_im(index, data2);
	sdsl::store_to_file(index, index_file);
}

int querycounts(string index_file, vector<vector<int> > queries,
		vector<int> &result) {
	// load suffix array and perform queries
	fm_index_word index;
	size_t i;

    if (!load_from_file(index, index_file))
		return 1;
	for (i = 0; i < queries.size(); ++i)
		result.push_back(sdsl::count(index,
					queries[i].begin(), queries[i].end()));
	return 0;
}

int queryindices(string index_file, vector<vector<int> > queries,
		vector<vector<int> > &result) {
	// load suffix array and perform queries
	fm_index_word index;
	size_t m;
	vector<int> query;

    if (!load_from_file(index, index_file))
		return 1;
	for (size_t i = 0; i < queries.size(); ++i) {
		query = queries[i];
		m = query.size();
		size_t cnt = sdsl::count(
				index, query.begin(), query.end());
		auto locations = sdsl::locate(
				index, query.begin(), query.begin() + m);
		for (size_t j = 0; j < cnt; ++j)
			result[i].push_back(locations[j]);
	}
	return 0;
}

void makeindex_char(string filename, string index_file) {
	// construct index directly from text file
	fm_index_char index;
	sdsl::construct(index, filename, 1);
	sdsl::store_to_file(index, index_file);
}

int querycounts_char(string index_file, vector<string> queries,
		vector<int> &result) {
	// load suffix array and perform queries
	fm_index_char index;
	size_t i;

    if (!load_from_file(index, index_file))
		return 1;
	for (i = 0; i < queries.size(); ++i)
		result.push_back(sdsl::count(index,
					queries[i].begin(), queries[i].end()));
	return 0;
}

int queryindices_char(string index_file, vector<string> queries,
		vector<vector<int> > &result) {
	// load suffix array and perform queries
	fm_index_char index;
	size_t m;
	string query;

    if (!load_from_file(index, index_file))
		return 1;
	for (size_t i = 0; i < queries.size(); ++i) {
		query = queries[i];
		m = query.size();
		size_t cnt = sdsl::count(
				index, query.begin(), query.end());
		auto locations = sdsl::locate(
				index, query.begin(), query.begin() + m);
		for (size_t j = 0; j < cnt; ++j)
			result[i].push_back(locations[j]);
	}
	return 0;
}
