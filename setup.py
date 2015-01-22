"""Generic setup.py for Cython code."""
import os
from distutils.core import setup
from distutils.extension import Extension
try:
	from Cython.Build import cythonize
	from Cython.Distutils import build_ext
	havecython = True
except ImportError as err:
	print(err)
	havecython = False

metadata = dict(name='fmindex',
		version='0.1pre1',
		description='FM Index',
		long_description=open('README.rst').read(),
		author='Andreas van Cranenburgh',
		author_email='A.W.vanCranenburgh@uva.nl',
		url='https://github.com/andreasvc/fmindex/',
		classifiers=[
				'Development Status :: 4 - Beta',
				'Intended Audience :: Science/Research',
				'License :: OSI Approved :: GNU General Public License (GPL)',
				'Operating System :: POSIX',
				'Programming Language :: Python :: 2.7',
				'Programming Language :: Python :: 3.3',
				'Programming Language :: Cython',
				'Topic :: Text Processing :: Linguistic',
		],
		requires=[
				'cython (>=0.20)',
		],
)

# some of these directives increase performance,
# but at the cost of failing in mysterious ways.
directives = {
		'profile': False,
		'cdivision': True,
		'fast_fail': True,
		'nonecheck': False,
		'wraparound': False,
		'boundscheck': False,
		'embedsignature': True,
		'warn.unused': True,
		'warn.unreachable': True,
		'warn.maybe_uninitialized': True,
		'warn.undeclared': False,
		'warn.unused_arg': False,
		'warn.unused_result': False,
		}

if __name__ == '__main__':
	if havecython:
		os.environ['GCC_COLORS'] = 'auto'
		extensions = [Extension(
				'*',
				sources=['*.pyx', '_fmindex.cpp'],
				language='c++',
				extra_compile_args=['-O3', '-std=c++11'],
				# extra_compile_args=['-O3', '-std=c++11', '-g', '-O0'],
				# extra_link_args=['-g'],
				libraries=['sdsl', 'divsufsort', 'divsufsort64'],
				library_dirs=[os.environ['HOME'] + '/.local/lib'],
				include_dirs=[os.environ['HOME'] + '/.local/include'],
				)]
		setup(
				cmdclass=dict(build_ext=build_ext),
				ext_modules=cythonize(
						extensions,
						annotate=True,
						compiler_directives=directives,
						# nthreads=4,
						# language_level=3,
				),
				# test_suite = 'tests'
				**metadata)
	else:
		setup(**metadata)
		print('\nWarning: Cython not found.\n')
