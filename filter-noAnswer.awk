function strip( thing ) {
    sub("  *$","",thing);sub("^  *","",thing);
    return thing;
}
function finish( id,doc,question,answer,candidates,    A,n,i ) {
    answer=tolower(strip(answer));
    doc=tolower(strip(doc));
    #print "id: " id,"doc: ",doc,"question: " question,"answer: " answer,"candidates:",candidates;
    if (index(doc,answer)==0) { 
	gsub("-"," ",answer);
	#print "re-answer: " answer;
	if (index(doc,answer)==0) { print id; }
    }
    #print "</entry>";
}
BEGIN { RS="\n\n";FS=OFS="\n";state="id"; }
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
    else if (state == "answer") { answer=$0; state="candidates"; }
    else if (state == "candidates") { candidates=$0; state="id"; }
}
END { finish(id,doc,question,answer,candidates); }
