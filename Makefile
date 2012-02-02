LATEX = pdflatex --interaction=nonstopmode
BIBTEX = bibtex
RM = rm -f

all: thesis

sections: intro.pdf fourier.pdf tfcns.pdf

thesis: thesis.pdf

clean:
	$(RM) *.{log,aux,toc,tof,tog,bbl,blg,pdfsync}

reallyclean:
	$(RM) *.pdf

RERUN = "(There were undefined references|Rerun to get (cross-references|the bars) right)"
RERUNBIB = "No file.*\.bbl|Citation.*undefined"
COPY = if test -r $*.toc; then cp $*.toc $*.toc.bak; fi

%.pdf: %.tex thesis.tex
	$(COPY);$(LATEX) $<
	egrep -c $(RERUNBIB) $*.log && ($(BIBTEX) $*;$(COPY);$(LATEX) $<) ; true
	
	egrep $(RERUN) $*.log && ($(COPY);$(LATEX) $<) ; true
	egrep $(RERUN) $*.log && ($(COPY);$(LATEX) $<) ; true
	if cmp -s $*.toc $*.toc.bak; then . ;else $(LATEX) $< ; fi
	$(RM) $*.toc.bak
	egrep -i "(Reference|Citation).*undefined" $*.log ; true
