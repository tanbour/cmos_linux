
SHELL	= /bin/sh
PYDIR	= /proj/onepiece4/Tools/python_3.6.3
INCDIR	= $(PYDIR)/include/python3.6m


PYTHON	= $(PYDIR)/bin/python3
CYTHON	= $(PYDIR)/bin/cython
CC	= gcc
CFLAGS	= -shared -pthread -fPIC -fwrapv -O2 -Wall -fno-strict-aliasing -I $(INCDIR)

CORE_DIR   := core
CYTHON_DIR := work_cython
OBJS       := $(addprefix $(CORE_DIR)/,\
  op_top.so	\
  op_lic.so	\
)

FILES = COPYING op op_license op_server
DIRS = core proj_share utils
SECURE_FILES = core/op_top.py core/op_lic.py core/__pycache__/op_top.*.pyc core/__pycache__/op_lic.*.pyc

.PHONY: all
all: $(OBJS) ;

clean:
	rm -f  $(OBJS)
	rm -rf $(CYTHON_DIR)

release: all
	@if [ "X$(release_dir)" = "X" ] ; then \
	  printf '\nplease specify release_dir\n\n  # make release release_dir=...\n\n' ;\
	  exit 1 ;\
	fi
	[ -d $(release_dir) ] || mkdir -m 755 -p $(release_dir)
	for file in $(FILES) ; do \
	    install -t $(release_dir) $$file ; \
	done
	for dir in $(DIRS) ; do \
	    rsync -rlE $$dir $(release_dir) ; \
	done
	for files in $(SECURE_FILES) ; do \
	    rm -f $(release_dir)/$$files ; \
	done


$(CYTHON_DIR)/%.c  : $(CORE_DIR)/%.py
	$(CYTHON) -o $@ $<

$(CORE_DIR)/%.so : $(CYTHON_DIR)/%.c
	$(CC) $(CFLAGS) -o $@ $<

$(OBJS): | $(CYTHON_DIR)

$(CYTHON_DIR):
	mkdir $(CYTHON_DIR)

