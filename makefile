a.out: main.o run_main.o func_select.o pstring.o
	gcc -g -no-pie -o a.out main.o run_main.o func_select.o pstring.o

main.o: main.c pstring.h
	gcc -g -c -no-pie -o main.o main.c

run_main.o: run_main.s pstring.h
	gcc -g -c -no-pie -o run_main.o run_main.s

func_select.o: func_select.s pstring.h
	gcc -g -c -no-pie -o func_select.o func_select.s

pstring.o: pstring.s
	gcc -g -c -no-pie -o pstring.o pstring.s	


clean:
	rm -f *.o a.out
