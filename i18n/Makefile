DOMAIN=foaf.vix
VERSION=1.0
MSGID_BUGS_ADDRESS=polak@gnu.org

MSGMERGE = msgmerge
MAKEPO = xmlt --load-path=. makepo

ifeq (LINGUAS,$(wildcard LINGUAS))
LINGUAS = $(shell sed 's/\#.*$$//;/^$$/d' LINGUAS)
else
LINGUAS = 
endif

all:	$(foreach lang, $(LINGUAS), $(lang).xml)

update:	$(foreach lang, $(LINGUAS), $(lang).po-update)

pot: $(DOMAIN).pot-update

# This target rebuilds $(DOMAIN).pot; it is an expensive operation.
# Note that $(DOMAIN).pot is not touched if it doesn't need to be changed.
$(DOMAIN).pot-update:
	$(MAKEPO) \
	     --package-name=$(DOMAIN) \
             --package-version=$(VERSION) \
             --bug-address='$(MSGID_BUGS_ADDRESS)' en.xml > $(DOMAIN).po
	test ! -f $(DOMAIN).po || { \
	  if test -f $(DOMAIN).pot; then \
	    sed -f remove-potcdate.sed < $(DOMAIN).pot > $(DOMAIN).1po && \
	    sed -f remove-potcdate.sed < $(DOMAIN).po > $(DOMAIN).2po && \
	    if cmp $(DOMAIN).1po $(DOMAIN).2po >/dev/null 2>&1; then \
	      rm -f $(DOMAIN).1po $(DOMAIN).2po $(DOMAIN).po; \
	    else \
	      rm -f $(DOMAIN).1po $(DOMAIN).2po $(DOMAIN).pot && \
	      mv $(DOMAIN).po $(DOMAIN).pot; \
	    fi; \
	  else \
	    mv $(DOMAIN).po $(DOMAIN).pot; \
	  fi; \
	}

.SUFFIXES: .po .xml .sed .sin .nop .po-create .po-update

.po.xml:
	$(MAKEPO) --gettext=$< en.xml > $@-t
	if test -s $@-t; then \
	  mv $@-t $@; \
	else \
	  rm $@-t; \
	fi

.sin.sed:
	sed -e '/^#/d' $< > t-$@
	mv t-$@ $@

.nop.po-create:
	@lang=`echo $@ | sed -e 's/\.po-create$$//'`; \
	echo "File $$lang.po does not exist. If you are a translator, you can create it through 'msginit'." 1>&2; \
	exit 1

.nop.po-update:
	@lang=`echo $@ | sed -e 's/\.po-update$$//'`; \
	if test "$(PACKAGE)" = "gettext-tools"; then PATH=`pwd`/../src:$$PATH; fi; \
	tmpdir=`pwd`; \
	echo "$$lang:"; \
	echo "$(MSGMERGE) $$lang.po $(DOMAIN).pot -o $$lang.new.po"; \
	if $(MSGMERGE) $$lang.po $(DOMAIN).pot -o $$tmpdir/$$lang.new.po; then \
	  if cmp $$lang.po $$tmpdir/$$lang.new.po >/dev/null 2>&1; then \
	    rm -f $$tmpdir/$$lang.new.po; \
	  else \
	    if mv -f $$tmpdir/$$lang.new.po $$lang.po; then \
	      :; \
	    else \
	      echo "msgmerge for $$lang.po failed: cannot move $$tmpdir/$$lang.new.po to $$lang.po" 1>&2; \
	      exit 1; \
	    fi; \
	  fi; \
	else \
	  echo "msgmerge for $$lang.po failed!" 1>&2; \
	  rm -f $$tmpdir/$$lang.new.po; \
	fi

$(foreach lang, $(LINGUAS), $(lang).nop):

clean: 
	rm $(foreach lang, $(LINGUAS), $(lang).xml)

foaf.vix.i18n.tar:
	tar cf foaf.vix.i18n.tar LINGUAS foaf.vix.pot Makefile xmltrans/makepo.scm *.xml *.po

archive: foaf.vix.i18n.tar

.PHONY: archive
