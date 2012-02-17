LATEX = pdflatex --interaction=nonstopmode
REDIR = 1>/dev/null 2>/dev/null
BIBTEX = bibtex
RM = rm -f

RERUN = "(There were undefined references|Rerun to get ((cross-references|the bars) right|citations correct))"
RERUNBIB = "No file.*\.bbl|Citation.*undefined"

TEXFILES = thesis.tex ack.tex intro.tex fourier.tex schwartz.tex tfcns.tex dists.tex conclusion.tex

.SILENT:

.PHONY: all pdf sections %-bib thesis-bib clean diffclean sageclean reallyclean

all: thesis.pdf

pdf: thesis.pdf

sections: intro.pdf fourier.pdf schwartz.pdf

%.pdf: %.tex chpreamble.tex vc.tex thesis.bib
# Run latex
	$(LATEX) $< $(REDIR); true
# Check if bib changed
	make $*-bib
# Check if sage changed; can't make recursively b/c latex overwrites the .sage
	diff $*.sage .$*.sage.bak || python sagetex/remote-sagetex.py -f remote-sagetex.conf $<
	cp $*.sage .$*.sage.bak
# Final run(s) of latex
	$(LATEX) $< $(REDIR)
	egrep $(RERUN) $*.log && $(LATEX) $< $(REDIR); true
	egrep $(RERUN) $*.log && $(LATEX) $< $(REDIR); true
	echo "*** Errors for $< ***"; true
	egrep -i "((Reference|Citation).*undefined|Unaddressed TODO)" $*.log ; true

vc.tex: vc vc-git.awk .git/logs/HEAD $(TEXFILES)
	sh vc -m

%-bib: %.tex thesis.bib %.bbl %.blg
	true

thesis-bib: $(TEXFILES) thesis.bib thesis.bbl thesis.blg

%.bbl %.blg: %.aux thesis.bib
	$(BIBTEX) $* $(REDIR); true
	$(LATEX) $< $(REDIR); true
	egrep -c $(RERUNBIB) $*.log $(REDIR) && ($(BIBTEX) $* $(REDIR);$(LATEX) $< $(REDIR)) ; true

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
	$(RM) *.sage *.sout
	$(RM) -r sage-plots-for-*

reallyclean:
	$(RM) *.pdf .*.sage.bak
