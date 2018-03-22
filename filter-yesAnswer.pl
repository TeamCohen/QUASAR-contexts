#!/usr/bin/perl
# syntax:
# perl filter-yesAnswer.pl no-answer.ids.txt output.txt > output.yes-answer.txt

my $idfn=shift;
my $outputfn=shift;

open(my $idf,"<$idfn") or die "Couldn't open $idfn for reading:\n$!\n";
open(my $outputf,"<$outputfn") or die "Couldn't open $outputfn for reading:\n$!\n";


my $state=0;
my $buf="";
my $pass=1;
my $id="";
my $n=0;

while(<$idf>) {
    chomp;
    my $skip=$_;
    if (length($id)>0) {
	$pass=idlt($id,$skip);
	#print "### Reading new skip: $id, $skip => $pass\n";
	if ($pass<0) {
	    next;
	}
    }
    while(<$outputf>) {
	$n++;
	#print "# '$_'\n";
	if ($_ =~ /^\n$/) {
	    #print "## state transition: $state\n";
	    # state transition
	    if ($state == 0) {
		$state++;
		# then we just finished id. Check it and set pass bit
		$id=$buf;
		chomp($id);
		$pass=idlt($id,$skip);
		$buf = $buf . $_;
		#print "### Current pass: $id, $skip => $pass\n";
		if ($pass<0) {
		    # break to outer loop to fetch another skip id
		    last;
		}
	    } elsif ($state == 4) { 
		$buf = $buf . $_;
		$state=0;
		if ($pass==1) { print $buf; }
		$buf="";
	    } else { 
		$buf = $buf . $_;
		$state++; 
	    }
	} else { 	
	    $buf = $buf . $_;
	}

	#($n<20000) or die "failed to parse";
    }
}
if (length($buf)>0) { print $buf; }
while(<$outputf>) {
    print $_;
}
close($idf);
close($outputf);

sub idlt{
    my $id=shift;
    my $skip=shift;
    my @ids=split("q",substr($id,1,length($id)-1));
    my @skips=split("q",substr($skip,1,length($skip)-1));
    if ($ids[1]<$skips[1] && $ids[0] <= $skips[0]) { return 1; }
    if ($ids[1]>=$skips[1] && $ids[0] < $skips[0]) { return 1; }
    if ($ids[1]==$skips[1] && $ids[0] == $skips[0]) { return 0; }
    return -1;
}
    
    
    
