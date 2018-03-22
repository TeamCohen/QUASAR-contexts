PROJECT:=trivia
LIB:=lib
CP:=${LIB}/*
MODE:=pagewise

# ClueWebClient produces the query -> {HTML pages} mapping we use as a
# prerequisite; email krivard@cs for details
CONTEXT:=${PROJECT}-context-batched.tsv
CLUEWEBCLIENT:=../clueweb-fetch
vpath %-context-batched.tsv ${CLUEWEBCLIENT}

default: $(SAMPLE)$(MODE)-output.set

%.set: %.txt %.1tok.txt %.yes-answer.txt %.1tok.yes-answer.txt %.no-answer.ids.txt
	true

${PROJECT}-export.xml:
	java -cp "${CP}" ${JAVARGS} -Dssquad.taggerModel=${LIB}/models/english-left3words-distsim.tagger edu.cmu.ml.ssquad.TriviaSentenceExport $(SKIP) ${CONTEXT} $@ 2>&1 | tee $(APPEND) make-$@.log  | grep -ve "PTBLexer next" -ve "WARNING: Untokenizable:" -ve "ERROR net.htmlparser.jericho"

${SAMPLE}sentencewise-output.txt.pre: ${SAMPLE}${CONTEXT}
	java -cp "${CP}" ${JAVARGS} -Dssquad.taggerModel=${LIB}/models/english-left3words-distsim.tagger edu.cmu.ml.ssquad.TriviaSentencewiseDataset $(SKIP) $< $@ 2>&1 | tee $(APPEND) make-$@.log  | grep -ve "PTBLexer next" -ve "WARNING: Untokenizable:" -ve "ERROR net.htmlparser.jericho"

${SAMPLE}sentencewise-output.txt:${SAMPLE}sentencewise-output.txt.pre
	awk -f postprocess.awk $< > $@


ifneq ($(SKIP),)
APPEND:=-a
endif
$(SAMPLE)pagewise-output.txt.pre: $(SAMPLE)${CONTEXT}
	java -cp "${CP}" ${JAVARGS} -Dssquad.taggerModel=${LIB}/models/english-left3words-distsim.tagger edu.cmu.ml.ssquad.TriviaPagewiseDataset $(SKIP) $< $@ 2>&1 | tee $(APPEND) make-$@.log | grep -ve "PTBLexer next" -ve "WARNING: Untokenizable:" -ve "ERROR net.htmlparser.jericho"

$(SAMPLE)pagewise-output.txt: $(SAMPLE)pagewise-output.txt.pre
	awk -f postprocess.awk $< > $@

%.no-answer.ids.txt: %.txt
	awk -f filter-noAnswer.awk $< > $@
#	grep "answer not found in text" make-$<.log | awk '{print $$2}' > $@

%.yes-answer.txt: %.no-answer.ids.txt %.txt 
	perl filter-yesAnswer.pl $^ > $@

%.1tok.txt: %.txt
	awk -f filter-1tok.awk $< > $@

%.1tok.yes-answer.txt: %.no-answer.ids.txt %.1tok.txt
	perl filter-yesAnswer.pl $^ > $@

TAB=$(shell echo "\t")
${PROJECT}-queries-fitb.tsv:
	sort -b ${PROJECT}-queries.tsv > ${PROJECT}-queries.sorted.tsv
	grep "of these" ${PROJECT}-queries.tsv | sort -b > ${PROJECT}-queries-multiplechoice.sorted.tsv
	comm -23 ${PROJECT}-queries.sorted.tsv ${PROJECT}-queries-multiplechoice.sorted.tsv | grep "^s" | \
	awk 'BEGIN{FS=OFS="\t"}{sheet=$$1;sub("s","",sheet);sub("q.*","",sheet); query=$$1; sub(".*q","",query); print sheet,query,$$1,$$2}' | \
	sort -k 1n,1 -k 2n,2 | \
	cut -f 3,4 > $@

${PROJECT}-context-fitb_batched.tsv: ${PROJECT}-queries-fitb.tsv ${PROJECT}-context_batched.tsv
	cut -f 1 $< | grep "^s" | sort -k 1b,1 > fitb-ids.txt
	sort -k 2b,2 $(word 2,$^) > $(word 2,$^).sorted
	join -t "${TAB}" -2 2 fitb-ids.txt $(word 2,$^).sorted | \
	awk 'BEGIN{FS=OFS="\t"}{sheet=$$1;sub("s","",sheet);sub("q.*","",sheet); query=$$1; sub(".*q","",query); print $$2,$$1,$$3,$$4,sheet,query}' | \
	sort -k 5n,5 -k 6n,6 | \
	cut -f 1,2,3,4 > $@


.SECONDARY:
