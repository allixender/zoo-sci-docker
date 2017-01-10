ZRPATH=../..
include ${ZRPATH}/zoo-kernel/ZOOMakefile.opts
CFLAGS=-I${INST_INCLUDE} ${ZOO_CFLAGS}

cgi-env/fortran_hello.zo: service.f
	gfortran -DZOO_SERVICE_PROVIDER ${CFLAGS} -shared -fpic -o cgi-env/fortran_hello.zo ./service.f -lzoo_service -L${INST_LIB}

clean:
	rm -f cgi-env/*.zo
