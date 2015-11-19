NAME ?= launcher
JARNAME ?= undefined

JOPTS = -O2 -Wall

CFILES = main.c utils.c
HFILES = messages.h  paths.h  utils.h
SOURCE = ${CFILES} ${HFILES}

MAKE ?= make
CC ?= gcc
STRIP ?= strip

OUTDIR=dist
OUTBIN=${OUTDIR}/${NAME}.${TARGET}

TARGET = ${shell uname -s|tr [A-Z] [a-z]}

compile:${OUTBIN}

clean:
	rm -rf ${OUTDIR}

${OUTDIR}:
	mkdir -p ${OUTDIR}

${OUTDIR}/${NAME}.linux:${OUTDIR} ${OUTDIR}/${NAME}.linux.32 ${SOURCE}
	${CC} ${JOPTS} -m64 -o ${OUTBIN} ${CFILES}
	strip -s ${OUTBIN}

${OUTDIR}/${NAME}.linux.32:${OUTDIR} ${SOURCE}
	${CC} ${JOPTS} -m32 -o ${OUTDIR}/${NAME}.linux.32 ${CFILES}
	strip -s ${OUTDIR}/${NAME}.linux.32

${OUTDIR}/${NAME}.darwin:${OUTDIR} ${SOURCE}
	${CC} ${JOPTS} -arch x86_64 -arch i386 -mmacosx-version-min=10.4 -o ${OUTBIN} ${CFILES}
	${STRIP} ${OUTBIN}

run:all
	./${NAME}32
