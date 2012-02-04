LATEX = pdflatex --interaction=nonstopmode
REDIR = 1>\dev\null 2>\dev\null
BIBTEX = bibtex
RM = rm -f

RERUN = "(There were undefined references|Rerun to get ((cross-references|the bars) right|citations correct))"
RERUNBIB = "No file.*\.bbl|Citation.*undefined"

.SILENT:

all: thesis.pdf

pdf: thesis.pdf

%.pdf: %.tex thesis.aux thesis.bbl thesis.blg
#	$(warning pdf target)
	$(LATEX) $< $(REDIR); true
	egrep $(RERUN) $*.log && $(LATEX) $< $(REDIR); true
	egrep $(RERUN) $*.log && $(LATEX) $< $(REDIR); true
	echo "*** Errors for $< ***"; true
	egrep -i "((Reference|Citation).*undefined)" $*.log ; true

thesis.bbl thesis.blg: thesis.tex thesis.bib thesis.aux 
#	$(warning bib target)
	$(BIBTEX) thesis $(REDIR); true
	$(LATEX) $< $(REDIR); true
	egrep -c $(RERUNBIB) thesis.log $(REDIR) && ($(BIBTEX) thesis $(REDIR);$(LATEX) $< $(REDIR)) ; true

thesis.aux: thesis.tex chpreamble.tex ack.tex intro.tex fourier.tex tfcns.tex dists.tex conclusion.tex vc.tex
#	$(warning aux target)
	$(LATEX) $< $(REDIR); true

sections: intro.pdf fourier.pdf tfcns.pdf

clean:
	$(RM) *.log *.aux *.toc *.tof *.tog *.bbl *.blg *.pdfsync *.d *.dvi vc.tex

reallyclean:
	$(RM) *.pdf

vc.tex: vc vc-git.awk .git/logs/HEAD
	sh $<
