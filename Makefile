.PHONY: clean all osx linux windows test

NAME=javalauncher

NIMFILES = $(wildcard *.nim *.c)

NIMOPTS=-d:release --opt:size

all:osx linux windows

clean:
	rm -rf target nimcache

osx:target/${NAME}.osx

linux:target/${NAME}.linux

windows:target/${NAME}.64.exe

target/${NAME}.osx:${NIMFILES}
	mkdir -p target
	nim c ${NIMOPTS} --passC="-mmacosx-version-min=10.7 -gfull" --passL="-mmacosx-version-min=10.7 -dead_strip" ${NAME}
	strip ${NAME}
	mv ${NAME} target/${NAME}.osx

target/${NAME}.linux:${NIMFILES}
	mkdir -p target
	docker run --rm -v `pwd`:/usr/src/app -w /usr/src/app teras/nimcross bash -c "nim c ${NIMOPTS} ${NAME} && strip ${NAME}"
	mv ${NAME} target/${NAME}.linux

target/${NAME}.64.exe:${NIMFILES}
	mkdir -p target
	docker run --rm -v `pwd`:/usr/src/app -w /usr/src/app teras/nimcross bash -c "nim c ${NIMOPTS} -d:mingw --cpu:i386  --app:gui ${NAME} && i686-w64-mingw32-strip   ${NAME}.exe"
	mv ${NAME}.exe target/${NAME}.32.exe
	docker run --rm -v `pwd`:/usr/src/app -w /usr/src/app teras/nimcross bash -c "nim c ${NIMOPTS} -d:mingw --cpu:amd64 --app:gui ${NAME} && x86_64-w64-mingw32-strip ${NAME}.exe"
	mv ${NAME}.exe target/${NAME}.64.exe


test:osx
	mkdir -p target/java/classes
	javac java/test.java -d target/java/classes
	jar cmf java/MANIFEST.MF target/java/test.jar  -C target/java/classes .
	./target/${NAME}.osx --javalauncher-creator --out target/java/test --json java/test.json
	target/java/test -Dvalue3=third_val param1 -Dvalue4=koko param2
