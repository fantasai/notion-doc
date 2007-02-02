# Settings
######################################

TOPDIR=../ion-3

include $(TOPDIR)/build/system-inc.mk

L2H=latex2html -show_section_numbers -short_index -local_icons -noaddress \
    -up_url http://iki.fi/tuomov/ion/ -up_title "Ion homepage" -nofootnode\
##    -style greyviolet.css


# Function documentation to build
######################################

DOCS=ionconf ionnotes

FNTEXES=ioncore-fns.tex mod_tiling-fns.tex \
	mod_query-fns.tex de-fns.tex mod_menu-fns.tex \
	mod_dock-fns.tex mod_sp-fns.tex mod_statusbar-fns.tex

# Generic rules
######################################

nothing:
	@ echo "Please read the README first."

%.ps: %.dvi
	dvips $<

%.pdf: %.dvi
	dvipdfm -p a4 $<

%.dvi: %.tex
	latex $<

# Install
######################################

install:
	$(INSTALLDIR) $(DOCDIR); \
	for d in $(DOCS); do \
	    for e in ps pdf dvi; do \
	      test -f $$d.$$e && $(INSTALL) -m $(DATA_MODE) $$d.$$e $(DOCDIR); \
            done; \
	    $(INSTALLDIR) $(DOCDIR)/$$d; \
            for i in $$d/*; do \
                $(INSTALL) -m $(DATA_MODE) $$i $(DOCDIR)/$$i; \
	    done; \
        done

# ionconf rules
######################################
ionconf-dvi-full:
	latex ionconf
	latex ionconf
	latex ionconf
	makeindex ionconf.idx
	latex ionconf

ionconf-html: 
	$(L2H) -split 3 ionconf

fntexes: $(FNTEXES)

ionconf-all: fntexes fnlist.tex ionconf-dvi-full ionconf-html

# ionnotes rules
######################################

ionnotes-dvi-full:
	latex ionnotes
	latex ionnotes
	latex ionnotes
	makeindex ionnotes.idx
	latex ionnotes

ionnotes-html: 
	$(L2H) -split 4 ionnotes

ionnotes-all: ionnotes-dvi-full ionnotes-html

# More generic rules
######################################

all: ionconf-all ionnotes-all

all-ps: ionconf.ps ionnotes.ps

all-pdf: ionconf.pdf ionnotes.pdf


# Clean
######################################

clean:
	rm -f $(FNTEXES) fnlist.tex
	rm -f *.aux *.toc *.log
	rm -f *.idx *.ild *.ilg *.ind
        
realclean: clean
	rm -f *.ps *.pdf *.dvi
	rm -rf $(DOCS)


# Function reference rules
######################################

ioncore-fns.tex: $(TOPDIR)/ioncore/*.c $(TOPDIR)/ioncore/*.lua
	$(MKEXPORTS) -module ioncore -mkdoc -o $@ $+

mod_tiling-fns.tex: $(TOPDIR)/mod_tiling/*.c
	$(MKEXPORTS) -module mod_tiling -mkdoc -o $@ $+

mod_query-fns.tex: $(TOPDIR)/mod_query/*.c $(TOPDIR)/mod_query/mod_query.lua
	$(MKEXPORTS) -module mod_query -mkdoc -o $@ $+

mod_menu-fns.tex: $(TOPDIR)/mod_menu/*.c $(TOPDIR)/mod_menu/mod_menu.lua
	$(MKEXPORTS) -module mod_menu -mkdoc -o $@ $+

mod_dock-fns.tex: $(TOPDIR)/mod_dock/*.c
	$(MKEXPORTS) -module mod_dock -mkdoc -o $@ $+

mod_sp-fns.tex: $(TOPDIR)/mod_sp/*.c
	$(MKEXPORTS) -module mod_sp -mkdoc -o $@ $+

mod_statusbar-fns.tex: $(TOPDIR)/mod_statusbar/*.c
	$(MKEXPORTS) -module mod_statusbar -mkdoc -o $@ $+

de-fns.tex: $(TOPDIR)/de/*.c
	$(MKEXPORTS) -module de -mkdoc -o $@ $+

# Function list
######################################

fnlist.tex: $(FNTEXES)
	grep hyperlabel $+ | \
	sed 's/.*fn:\([^}]*\).*/\\fnlisti{\1}/;'|sort -d -f \
	> $@
