all:
	python setup.py install --user

clean:
	rm -f fmindex.so fmindex.cpp fmindex.html

test: all
	python fmgrep.py /usr/share/dict/words LICENSE

lint:
	pep8 --ignore=E1,W1,F,E901,E225,E227,E211 \
			*.py *.pyx *.pxd *.pxi

py3:
	python3 setup.py install --user

test3: py3
	python3 fmgrep.py /usr/share/dict/words LICENSE
