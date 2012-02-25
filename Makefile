LATEX = pdflatex --interaction=nonstopmode
REDIR = 1>/dev/null 2>/dev/null
BIBTEX = bibtex
RM = rm -f

RERUN = "(There were undefined references|Rerun to get ((cross-references|the bars) right|citations correct))"
RERUNBIB = "No file.*\.bbl|Citation.*undefined"

TEXFILES = thesis.tex ack.tex intro.tex fourier.tex schwartz.tex tfcns.tex dists.tex conclusion.tex limits.tex

.SILENT:

.PHONY: all pdf sections %-bib thesis-bib clean diffclean sageclean reallyclean

all: thesis.pdf

pdf: thesis.pdf

sections: intro.pdf fourier.pdf schwartz.pdf limits.pdf

%.pdf: %.tex %.aux %.sout %.bbl %.blg chpreamble.tex vc.tex
	$(LATEX) $< #$(REDIR)
	egrep $(RERUN) $*.log && $(LATEX) $< $(REDIR); true
	egrep $(RERUN) $*.log && $(LATEX) $< $(REDIR); true
	echo "*** Errors for $< ***"; true
	egrep -i "((Reference|Citation).*undefined|Unaddressed TODO)" $*.log ; true

vc.tex: vc vc-git.awk .git/logs/HEAD $(TEXFILES)
	sh vc -m

thesis.aux thesis.sage: $(TEXFILES)
	$(LATEX) $< $(REDIR); true

%.aux %.sage: %.tex
	$(LATEX) $< $(REDIR); true

%.sout: %.sage
# Check if sage changed; can't use dates b/c latex overwrites the .sage
	(!(diff $*.sage .$*.sage.bak) && ((python sagetex/remote-sagetex.py -f remote-sagetex.conf $< && cp $*.sage .$*.sage.bak) || echo "\n Did not run sage; re-run with a valid connection!\n")); true

%.bbl %.blg: %.aux thesis.bib
# Dependence on the aux makes sure we rerun when changed, but will fire too often
	$(BIBTEX) $* $(REDIR); true
	$(LATEX) $* $(REDIR); true
	egrep -c $(RERUNBIB) $*.log $(REDIR) && ($(BIBTEX) $* $(REDIR);$(LATEX) $* $(REDIR)) ; true

%-diff: %.tex thesis.tex chpreamble.tex vc.tex
	latexdiff-git --force $<

%-diff-commit: %.tex thesis.tex chpreamble.tex vc.tex
	echo "enter commit ID for diff:";\
	read revision;\
	latexdiff-git --commit=$$revision --force $<

clean: diffclean sageclean
	$(RM) *.log *.aux *.toc *.tof *.tog *.bbl *.blg *.pdfsync *.d *.dvi *.out *.thm vc.tex

diffclean:
	$(RM) *_new.tex *_old.tex *_diff.*

sageclean:
	$(RM) *.sage *.sout .*.sage.bak
	$(RM) -r sage-plots-for-*

reallyclean:
	$(RM) *.pdf
