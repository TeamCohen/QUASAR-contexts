function strip( thing ) {
    sub("  *$","",thing);sub("^  *","",thing);
    return thing;
}
function finish( id,doc,question,answer,candidates,    A,n,i ) {
    answer=strip(answer);
    doc=strip(doc);
    print id;
    print doc;
    print question;
    print answer;
    print candidates;
}
BEGIN { RS=ORS="\n\n";FS=OFS="\n";state="id"; }
{
    if (state == "id") {
	if (id) { 
	    finish(id,doc,question,answer,candidates);
	}
	for(i=1;i<=NF;i++) {id=$i; if (id !~ /^[#]/) break;}
	state="doc";
    }
    else if (state == "doc") { doc=$0; state="question"; }
    else if (state == "question") { question=$0; state="answer"; }
    else if (state == "answer") { answer=$0; sub("  *\.$","",answer); state="candidates"; }
    else if (state == "candidates") { candidates=$0; gsub("  *\.\t","\t",candidates); state="id"; }
}
END { finish(id,doc,question,answer,candidates); }
