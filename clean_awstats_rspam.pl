#!/usr/bin/perl
#g0 2013
#clean_awstats_rspam.pl
#clean up awstats referral spam
#http://alog.ipduh.com/2013/06/clean-up-awstats-referral-spam.html
# usage: 
# ./clean_awstats_rspam.pl awstats062013.example.com.txt >> clean_awstats062013.example.com.txt;
# cp clean_awstats062013.example.com.txt awstats062013.example.com.txt

use strict;

#set to 1 if you want to get rid off subdomains of blaclisted domains
my $bl_subdomains=1;
#location of your blacklist.txt file
my $blacklist="/var/www/sites/example.com/awstats/lib/blacklist.txt";
#set to 1 if you want to log the count of spam referral links removed to the awstatsMMYYYY.example.com.txt file
my $rlog=0;

my %spamdoms=();
my $logtxt=$ARGV[0];
my $foundspam=0;	
my $crap=0;
my $me="clean_awstats_rspam";

open FH, "$blacklist" or die "$me:I could not open $blacklist ($!)";
while (<FH>)
{
	chomp;
	if(/^#/) { next; }
	$_=~s/^\s+//;
	$_=~s/\s+$//;
	unless($spamdoms{$_})
	{
	 	$spamdoms{$_}=1;
	}		
}
close FH;

my @spamdoms=keys %spamdoms;
%spamdoms=();

open FH, "$logtxt" or die "$me:I could not open $logtxt ($!)";
while (<FH>)
{

	if(/^#/) { print $_ ; next; }
	unless(/^http/) { print $_ ; next; }
OOF:{
	$foundspam=0;	
	for my $spamdom (@spamdoms)
	{
	   if( $bl_subdomains )
           {
		if( /^http:\/\/$spamdom/ || /^http:\/\/[a-z0-9A-Z\-\.]*\.$spamdom/ )
		{ 	
			$crap++;
			$foundspam=1;	
			last OOF;
		}
           }else{
  		if( /^http:\/\/$spamdom/ )
		{
			$crap++;
                        $foundspam=1;
                        last OOF;
		}
           }
	}
	print $_;
    }
	
}
close FH;

print "$me:removed $crap referrals\n" if($rlog);
