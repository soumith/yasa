my $dataroot = '/scratch/sc3104/snap-twitter7/';

#my $filename = 'tweets2009-06.txt';

my @filenames = ("tweets2009-06.txt","tweets2009-07.txt","tweets2009-08.txt","tweets2009-09.txt","tweets2009-10.txt","tweets2009-11.txt","tweets2009-12.txt");
foreach $filename (@filenames) {
    my $fullname = $dataroot . $filename;
    my $outfilename = $filename."preprocessed1.txt";
    my $outfullname = $dataroot . $outfilename;
    processSNAPFile($fullname, $outfullname);
}

sub processSNAPFile {

    my $fullname = $_[0];
    my $outfullname = $_[1];

    open (OUTFILE, '>'.$outfullname);
    print "reading from:" . $fullname . "\n";
    open FH,$fullname or die;

#calculate number of tweets from line 1
    my $length_line = <FH>;
    my @length = split(/:/,$length_line);
    $length = $length[1];
    print "Length is:". $length;

    my $count_processed = 0;
    my $progress_show = 0;
    my $progress_rate = 50000;
#for each line in array
#foreach (@array)
    while (my $line = <FH>) {
	#    $line = $_;
	#convert to lower-case
	$line =~ tr/A-Z/a-z/;
	#split it into tokens
	#tokenize over .,!()\s
	$delimiters = " ";
	@tokens= split(/[,\t\s!()"*]+/,$line);
	#find tweets(start with W)
	if($tokens[0] eq "w") {
	    my $processed_tweet = "";
	    #for each tweet, iterate over words
	    for($iter = 1; $iter <@tokens;$iter++) {
		
		#process retweets
		if(($tokens[$iter] eq "rt") || ($tokens[$iter] eq "rt.")) {
		    $tokens[$iter] = "";
		    if( ($iter + 1) < @tokens ) {
			$tokens[ $iter + 1 ] = "";
		    }
		}


		$first_char = substr( $tokens[$iter], 0, 1 );
		if($first_char eq "@") {
		    #process usernames
		    $tokens[$iter] = "";
		}
		elsif($first_char eq "#") {
		    #process hashtags
		    $tokens[$iter] = "HASHTAG";
		}

		#strip URLs
		if($tokens[$iter] =~ m/(.+\..+\/.+)|(.+\..+\..+)/) {
		    $tokens[$iter] = "";
		}
		
		#strip . characters
		$tokens[$iter] =~ s/\.|\-|'|:|’|\|//g;

		$processed_tweet = $processed_tweet . $tokens[$iter]." ";
	    }
	    print OUTFILE $processed_tweet."\n";
	    $count_processed = $count_processed + 1;
	    $progress_show = $progress_show + 1;
	    if($progress_show == $progress_rate) {
		my $percent = ($count_processed/$length * 100);
		print $fullname."\t:\t" . $count_processed . " of " . $length ."\t". $percent."%\n";
		$progress_show = 0;
	    }
	}
    }

    close(FH);
    close(OUTFILE);

}
