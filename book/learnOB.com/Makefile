index.html: head footer index.awk
	newfirst=`echo 20*/*/*.md | awk '{ for (i=NF; i>1; i--) printf("%s ", $$i); print $$1; }'` && \
	awk -f index.awk $$newfirst | cat head /dev/stdin footer > index.html

.SUFFIXES: .md .html
.md.html: head articlehead articlefooter footer
	lowdown $< | cat head articlehead /dev/stdin articlefooter footer > $@

clean:
	rm -f *.html 20*/*/*.html
