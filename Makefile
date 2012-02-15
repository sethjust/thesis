LATEX = pdflatex --interaction=nonstopmode
REDIR = 1>/dev/null 2>/dev/null
BIBTEX = bibtex
RM = rm -f

RERUN = "(There were undefined references|Rerun to get ((cross-references|the bars) right|citations correct))"
RERUNBIB = "No file.*\.bbl|Citation.*undefined"

TEXFILES = thesis.tex chpreamble.tex ack.tex intro.tex fourier.tex schwartz.tex tfcns.tex dists.tex conclusion.tex

.SILENT:

all: thesis.pdf

pdf: thesis.pdf

%.pdf: %.tex thesis.aux thesis.bbl thesis.blg
#	$(warning pdf target)
	diff $*.sage .$*.sage.bak || make $*.sout
	cp $*.sage .$*.sage.bak
	$(LATEX) $< 
	egrep $(RERUN) $*.log && $(LATEX) $< $(REDIR); true
	egrep $(RERUN) $*.log && $(LATEX) $< $(REDIR); true
	echo "*** Errors for $< ***"; true
	egrep -i "((Reference|Citation).*undefined|Unaddressed TODO)" $*.log ; true

thesis.bbl thesis.blg: thesis.tex thesis.bib thesis.aux 
#	$(warning bib target)
	$(BIBTEX) thesis $(REDIR); true
	$(LATEX) $< $(REDIR); true
	egrep -c $(RERUNBIB) thesis.log $(REDIR) && ($(BIBTEX) thesis $(REDIR);$(LATEX) $< $(REDIR)) ; true

thesis.aux: $(TEXFILES) vc.tex
#	$(warning aux target)
	$(LATEX) $< $(REDIR); true

%.sout: %.sage 
	python sagetex/remote-sagetex.py -f remote-sagetex.conf $<

sections: intro.pdf fourier.pdf tfcns.pdf

%-diff: %.tex thesis.tex chpreamble.tex vc.tex
	latexdiff-git --force $<

%-diff-commit: %.tex thesis.tex chpreamble.tex vc.tex
	echo "enter commit ID for diff:";\
	read revision;\
	latexdiff-git --commit=$$revision --force $<

vc.tex: vc vc-git.awk .git/logs/HEAD $(TEXFILES)
	sh vc -m

clean: diffclean sageclean
	$(RM) *.log *.aux *.toc *.tof *.tog *.bbl *.blg *.pdfsync *.d *.dvi *.out *.thm vc.tex

diffclean:
	$(RM) *_new.tex *_old.tex *_diff.*

sageclean:
	$(RM) *.sage *.sout .*.sage.bak
	$(RM) -r sage-plots-for-*

reallyclean:
	$(RM) *.pdf
