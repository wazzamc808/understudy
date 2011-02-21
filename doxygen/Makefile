export SRCROOT=..

all: UND/index.html

UND/index.html: BR/index.html
	doxygen UND.Doxyfile

BR/index.html: $(wildcard ${SRCROOT}/BRHeaders/*.h)
	doxygen BR.Doxyfile
