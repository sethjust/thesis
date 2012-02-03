LATEX = pdflatex --interaction=nonstopmode
BIBTEX = bibtex
RM = rm -f

RERUN = "(There were undefined references|Rerun to get ((cross-references|the bars) right|citations correct))"
RERUNBIB = "No file.*\.bbl|Citation.*undefined"

all: thesis.pdf

pdf: thesis.pdf

%.pdf: %.tex thesis.bbl thesis.blg
	$(LATEX) $<
	
	egrep $(RERUN) $*.log && $(LATEX) $< ; true
	egrep $(RERUN) $*.log && $(LATEX) $< ; true
	egrep -i "(Reference|Citation).*undefined" $*.log ; true

thesis.bbl thesis.blg: thesis.tex thesis.bib thesis.aux 
	$(BIBTEX) thesis; true
	$(LATEX) $<
	egrep -c $(RERUNBIB) thesis.log && ($(BIBTEX) thesis;$(LATEX) $<) ; true

thesis.aux: thesis.tex chpreamble.tex ack.tex intro.tex fourier.tex tfcns.tex dists.tex conclusion.tex vc.tex
	$(LATEX) $<

sections: intro.pdf fourier.pdf tfcns.pdf

clean:
	$(RM) *.log *.aux *.toc *.tof *.tog *.bbl *.blg *.pdfsync *.d *.dvi vc.tex

reallyclean:
	$(RM) *.pdf

vc.tex: vc vc-git.awk .git/logs/HEAD
	sh $<
