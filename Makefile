.PHONY: clean all osx linux test

NIMFILES = $(wildcard *.nim *.c)

all:osx linux

clean:
	rm -rf target

osx:target/javalauncher.osx

linux:target/javalauncher.linux

target/javalauncher.osx:${NIMFILES}
	nim c -d:release --opt:size javalauncher
	strip javalauncher
	mkdir -p target
	mv javalauncher target/javalauncher.osx

target/javalauncher.linux:${NIMFILES}
	docker run --rm -v `pwd`:/usr/src/app -w /usr/src/app nimlang/nim nim c -d:release --opt:size javalauncher
	docker run --rm -v `pwd`:/usr/src/app -w /usr/src/app nimlang/nim strip javalauncher
	mkdir -p target
	mv javalauncher target/javalauncher.linux

test:osx
	mkdir -p target/java/classes
	javac java/test.java -d target/java/classes
	mkdir -p target/java/classes/META-INF
	cp java/LAUNCHER.INF target/java/classes/META-INF
	jar cmf java/MANIFEST.MF target/java/test.jar  -C target/java/classes .
	cp target/javalauncher.osx target/java/test
	target/java/test param1 param2
