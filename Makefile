JAR ?= test/test.jar
NAME=launcher

CFILES = $(wildcard *.c utils/*.c minizip/*.c jar/*.c)
HFILES = $(wildcard *.h utils/*.h minizip/*.h jar/*h)
SOURCE = ${CFILES} ${HFILES}

CFLAGS=-lz -Oz -I. -Iutils -Iminizip -Ijar -Wall

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

${BUILD}/${NAME}.linux:${BUILD}/${NAME}.linux64 ${BUILD}/${NAME}.linux32

${BUILD}/${NAME}.linux64:${BUILD} ${SOURCE}
	${CC} ${CFLAGS} -m64 -o ${BINFILE}64 ${CFILES}
	strip -s ${BINFILE}64

${BUILD}/${NAME}.linux32:${BUILD} ${SOURCE}
	${CC} ${CFLAGS} -m32 -o ${BINFILE}32 ${CFILES}
	strip -s ${BINFILE}32


${BUILD}/${NAME}.darwin:${BUILD} ${SOURCE}
	${CC} ${CFLAGS} -arch x86_64 -arch i386 -mmacosx-version-min=10.4 -o ${BINFILE} ${CFILES}
	${STRIP} ${BINFILE}


${EXEFILE}:${DIST} ${BINFILE}
	cat ${BINFILE} ${JAR} >${EXEFILE}
	chmod a+x ${EXEFILE}

