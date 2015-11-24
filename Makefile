JAR ?= test/test.jar
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

BUILD=build
DIST=dist
BINFILE=${BUILD}/${NAME}.${TARGET}
EXEFILE=${DIST}/${NAME}

TARGET = ${shell uname -s|tr [A-Z] [a-z]}

all:compile
	${EXEFILE} one two three
	LAUNCHER_DEBUG=true ${EXEFILE} four five six seven eight nine ten

compile:${EXEFILE}

clean:
	rm -rf ${BUILD} ${DIST}

${BUILD}:
	mkdir -p ${BUILD}

${DIST}:
	mkdir -p ${DIST}

${BUILD}/${NAME}.linux:${BUILD} ${SOURCE} ${EXEFILE}32
	${CC} ${CFILES} -o ${BINFILE} -m64 ${CFLAGS}
	strip -s ${BINFILE}

${BUILD}/${NAME}.linux32:${BUILD} ${SOURCE}
	${CC} ${CFILES} -o ${BINFILE}32 -m32 ${CFLAGS}
	strip -s ${BINFILE}32

${BUILD}/${NAME}.darwin:${BUILD} ${SOURCE}
	${CC} ${CFLAGS} -arch x86_64 -arch i386 -mmacosx-version-min=10.4 -o ${BINFILE} ${CFILES}
	${STRIP} ${BINFILE}


${EXEFILE}:${DIST} ${BINFILE}
	cat ${BINFILE} ${JAR} >${EXEFILE}
	chmod a+x ${EXEFILE}

${EXEFILE}32:${DIST} ${BINFILE}32
	cat ${BINFILE}32 ${JAR} >${EXEFILE}32
	chmod a+x ${EXEFILE}32
