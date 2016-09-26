JARTEST ?= test/test.jar

NAME=launcher

CFILES = $(wildcard *.c utils/*.c lib/*.c core/*.c)
HFILES = $(wildcard *.h utils/*.h lib/*.h core/*h)
SOURCE = ${CFILES} ${HFILES}

SIZEOPT=-Os
#SIZEOPT=-Oz

CFLAGS=-DJSMN_PARENT_LINKS -lz ${SIZEOPT} -I. -Iutils -Ilib -Icore -Wall

MAKE ?= make
CC ?= gcc
STRIP ?= strip

DIST=dist
BINBASE=${DIST}/${NAME}
BINFILE=${BINBASE}.${TARGET}
TESTFILE=${DIST}/${NAME}

TARGET = ${shell uname -s|tr [A-Z] [a-z]}

.PHONY: compile
compile:${BINFILE}

.PHONY: test
test:${TESTFILE}
	${TESTFILE} one δύο

.PHONY: test32
test32:${TESTFILE}32
	${TESTFILE}32 one δύο

.PHONY: testdebug
testdebug:${TESTFILE}
	LAUNCHER_DEBUG=true ${TESTFILE} one δύο

.PHONY: clean
clean:
	rm -rf ${DIST}

${DIST}:
	mkdir -p ${DIST}

${BINBASE}.linux:${DIST} ${SOURCE} ${BINFILE}32
	${CC} ${CFILES} -o ${BINFILE} -m64 ${CFLAGS}
	strip -s ${BINFILE}

${BINBASE}.linux32:${DIST} ${SOURCE}
	${CC} ${CFILES} -o ${BINFILE}32 -m32 ${CFLAGS}
	strip -s ${BINFILE}32

${BINBASE}.darwin:${DIST} ${SOURCE}
	${CC} ${CFLAGS} -arch x86_64 -arch i386 -mmacosx-version-min=10.4 -o ${BINFILE} ${CFILES}
	${STRIP} ${BINFILE}

${TESTFILE}:${DIST} ${BINFILE} ${JARTEST}
	cat ${BINFILE} ${JARTEST} >${TESTFILE}
	chmod a+x ${TESTFILE}

${TESTFILE}32:${DIST} ${BINFILE}32 ${JARTEST}
	cat ${BINFILE}32 ${JARTEST} >${TESTFILE}32
	chmod a+x ${TESTFILE}32
