FROM teras/nimcross:javalauncher

COPY *.nim *.c ./
COPY include ./include
