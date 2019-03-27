VERSION=$(shell awk '/Version:/ { print $$2 }' alternatives.spec)
TAG = $(VERSION)

CFLAGS=-g -Wall $(RPM_OPT_FLAGS) -D_GNU_SOURCE
LDFLAGS+=-g
MAN=alternatives.8
BINDIR = /sbin
SBINDIR = /usr/sbin
MANDIR = /usr/man
ALTDIR = /var/lib/alternatives
ALTDATADIR = /etc/alternatives
SUBDIRS = po

all: subdirs alternatives

subdirs:
	for d in $(SUBDIRS); do \
	(cd $$d; $(MAKE)) \
	|| case "$(MFLAGS)" in *k*) fail=yes;; *) exit 1;; esac;\
	done && test -z "$$fail"

alternatives: alternatives.o

alternatives.o: alternatives.c
	$(CC) $(CFLAGS) -DVERSION=\"$(VERSION)\" -c alternatives.c

clean:
	rm -f alternatives alternatives.o
	make -C po clean

install:
	[ -d $(DESTDIR)/$(BINDIR) ] || mkdir -p $(DESTDIR)/$(BINDIR)
	[ -d $(DESTDIR)/$(SBINDIR) ] || mkdir -p $(DESTDIR)/$(SBINDIR)
	[ -d $(DESTDIR)/$(MANDIR) ] || mkdir -p $(DESTDIR)/$(MANDIR)
	[ -d $(DESTDIR)/$(MANDIR)/man8 ] || mkdir -p $(DESTDIR)/$(MANDIR)/man8
	[ -d $(DESTDIR)/$(ALTDIR) ] || mkdir -p -m 755 $(DESTDIR)/$(ALTDIR)
	[ -d $(DESTDIR)/$(ALTDATADIR) ] || mkdir -p -m 755 $(DESTDIR)/$(ALTDATADIR)

	install -m 755 alternatives $(DESTDIR)/$(SBINDIR)/alternatives
	ln -s alternatives $(DESTDIR)/$(SBINDIR)/update-alternatives

	for i in $(MAN); do \
		install -m 644 $$i $(DESTDIR)/$(MANDIR)/man`echo $$i | sed "s/.*\.//"`/$$i ; \
	done

	ln -s alternatives.8 $(DESTDIR)/$(MANDIR)/man8/update-alternatives.8

	for d in $(SUBDIRS); do \
	(cd $$d; $(MAKE) install) \
	    || case "$(MFLAGS)" in *k*) fail=yes;; *) exit 1;; esac;\
	done && test -z "$$fail"

tag:
	@git tag -a -m "Tag as $(TAG)" -f $(TAG)
	@echo "Tagged as $(TAG)"

check: alternatives
	./test-alternatives.sh
