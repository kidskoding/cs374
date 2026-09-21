TYPST ?= typst

LECTURES := $(wildcard lec[0-9]*.typ)
LECTURE_PDFS := $(patsubst %.typ,lectures/%.pdf,$(LECTURES))
HOMEWORKS := $(wildcard homeworks/typst/*.typ)
HOMEWORK_PDFS := $(patsubst homeworks/typst/%.typ,homeworks/pdfs/%.pdf,$(HOMEWORKS))
BOOK_SOURCES := $(LECTURES) $(wildcard labs/*.typ problem-sets/*.typ)
DIAGRAMS := $(wildcard homeworks/diagrams/*.svg)

.PHONY: all book lectures homeworks watch
all: book lectures homeworks
book: cs374.pdf
lectures: $(LECTURE_PDFS)
homeworks: $(HOMEWORK_PDFS)

cs374.pdf: cs374.typ setup.typ $(BOOK_SOURCES)
	$(TYPST) compile --root . $< $@

lectures/%.pdf: %.typ setup.typ
	@mkdir -p lectures
	$(TYPST) compile --root . $< $@

homeworks/pdfs/%.pdf: homeworks/typst/%.typ setup.typ $(DIAGRAMS)
	@mkdir -p homeworks/pdfs
	$(TYPST) compile --root . $< $@

watch:
	$(TYPST) watch --root . cs374.typ cs374.pdf
