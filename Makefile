all:
	python setup.py install --user

inplace:
	python setup.py build_ext --inplace

clean:
	rm -f fmindex.so fmindex.cpp fmindex.html
