
prefix=$(PPFX_FQ_DIR)
OBJS_LIB = $(shell ls src/*.cpp | sed 's/\.cpp/.o/')
PROGS = $(shell ls src/*.C | sed 's/\.C//' | sed 's/src\///')
INCLUDES = -I./include -I$(shell root-config --incdir) -I$(BOOST_INC) -I$(DK2NU_INC)
DEPLIBS=$(shell root-config --libs) -lEG 

CC	=	g++
COPTS	=	-fPIC -DLINUX -O0  -g $(shell root-config --cflags) 
FLAGS   =       -g

all:  mklibbin lib programs

lib: libppfx.so 

mklibbin:
	if [ ! -d $(prefix)/lib ]; then mkdir -p $(prefix)/lib; fi
	if [ ! -d $(prefix)/bin ]; then mkdir -p $(prefix)/bin; fi

libppfx.so: $(OBJS_LIB)
	$(CC) -shared -o $(prefix)/lib/$@ $^ -L$(DK2NU_LIB) -ldk2nuTree $(DEPLIBS)


programs: $(PROGS)
	echo making $(PROGS)

$(PROGS): % : src/%.o $(OBJS_LIB)  libppfx.so
	$(CC) -Wall -o $(prefix)/bin/$@ $< $(PPFX_OBJS) $(DEPLIBS) \
	      -L$(prefix)/lib -lppfx -L$(DK2NU_LIB) -ldk2nuTree


%.o: %.cpp
	$(CC) $(COPTS) $(INCLUDES) -c -o $@ $<


%.o: %.C
	$(CC) $(COPTS) $(INCLUDES) -c -o $@ $<

%.o: %.cxx
	$(CC) $(COPTS) $(INCLUDES) -c -o $@ $<

doxy: 
	doxygen doxygen/config_doxygen

clean:  deldoxy delobj dellib delbin

delobj:
	-rm src/*.o

dellib:
	if [ -d $(prefix)/lib ]; then rm -rf $(prefix)/lib; fi 		

delbin:
	if [ -d $(prefix)/bin ]; then rm -rf $(prefix)/bin; fi

deldoxy:
	if [ -d html ]; then rm -rf html; fi
	if [ -d latex ]; then rm -rf latex; fi



