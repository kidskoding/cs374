TYPST ?= typst

LECTURES := $(wildcard lec[0-9]*.typ)
LECTURE_PDFS := $(patsubst %.typ,lectures/%.pdf,$(LECTURES))
HOMEWORKS := $(wildcard homeworks/typst/*.typ)
HOMEWORK_PDFS := $(patsubst homeworks/typst/%.typ,homeworks/pdfs/%.pdf,$(HOMEWORKS))
LABS := $(wildcard labs/*.typ)
LAB_PDFS := $(patsubst labs/%.typ,labs/pdfs/%.pdf,$(LABS))
PROBLEM_SETS := $(wildcard problem-sets/*.typ)
PROBLEM_SET_PDFS := $(patsubst problem-sets/%.typ,problem-sets/pdfs/%.pdf,$(PROBLEM_SETS))
BOOK_SOURCES := $(LECTURES) $(wildcard labs/*.typ problem-sets/*.typ)
DIAGRAMS := $(wildcard homeworks/diagrams/*.svg)

.PHONY: all book lectures homeworks labs problem-sets watch
all: book lectures homeworks labs problem-sets
book: cs374.pdf
lectures: $(LECTURE_PDFS)
homeworks: $(HOMEWORK_PDFS)
labs: $(LAB_PDFS)
problem-sets: $(PROBLEM_SET_PDFS)

cs374.pdf: cs374.typ setup.typ $(BOOK_SOURCES)
	$(TYPST) compile --root . $< $@

lectures/%.pdf: %.typ setup.typ
	@mkdir -p lectures
	$(TYPST) compile --root . $< $@

homeworks/pdfs/%.pdf: homeworks/typst/%.typ setup.typ $(DIAGRAMS)
	@mkdir -p homeworks/pdfs
	$(TYPST) compile --root . $< $@

labs/pdfs/%.pdf: labs/%.typ setup.typ
	@mkdir -p labs/pdfs
	$(TYPST) compile --root . $< $@

problem-sets/pdfs/%.pdf: problem-sets/%.typ setup.typ
	@mkdir -p problem-sets/pdfs
	$(TYPST) compile --root . $< $@

watch:
	$(TYPST) watch --root . cs374.typ cs374.pdf
