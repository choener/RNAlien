#!/usr/bin/perl

use warnings;
use strict;
use diagnostics;
#use utf8;
use Data::Dumper;
use Cwd;
$|=1;
#decideds which benchmark data to process
my $type = "structured";

#contains all RNAlien result folders for sRNA tagged families
my $alienresult_basename;
#contains all Rfam Families names by family name with extension .cm
my $rfammodel_basename;
#contains all full seed alignment sequences as RfamID .fa fasta files
my $rfamfasta_basename;
my $RNAFamilyIdFile;
my $familyNumber;
my $resulttempdir;
if($type eq "structured"){
	$alienresult_basename="/scr/kronos/egg/AlienStructuredResultsCollected4/";
	$rfammodel_basename = "/scr/kronos/egg/AlienTest/sRNAFamilies/all_models/";
	#$rfamfasta_basename = "/scr/kronos/egg/rfamfamilyfasta/";
	$rfamfasta_basename = "/scr/kronos/egg/rfamfamilyseedfasta/";
	$RNAFamilyIdFile = "/scr/kronos/egg/structuredFamilyNameIdGatheringCutoffSorted";
	$familyNumber = 56;
	$resulttempdir = "/scr/kronos/egg/temp/AlienStructuredResultStatistics3";
}else{
	#sRNA
	$alienresult_basename="/scr/kronos/egg/AlienResultsCollected/";
	$rfammodel_basename = "/scr/kronos/egg/AlienTest/sRNAFamilies/all_models/";
	$rfamfasta_basename = "/scr/kronos/egg/rfamfamilyfasta/";
	$RNAFamilyIdFile = "/scr/kronos/egg/sRNAFamiliesIdNameGatheringCutoffTagSorted";
        $familyNumber = 374;
	$resulttempdir = "/scr/kronos/egg/temp/AlienResultStatistics";
}


my @RNAfamilies;
open(my $RNAfamilyfh, "<", $RNAFamilyIdFile)
    or die "Failed to open file: $!\n";
while(<$RNAfamilyfh>) {
    chomp;
    push @RNAfamilies, $_;
}
close $RNAfamilyfh;
my $gathering_score_multiplier = 1.5;  # 1.5 1.4 1.3 1.2 1.1 1 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.1
=pod
for(1..15){
    my $output;
    for(my $counter=1; $counter <= $familyNumber; $counter++){
        my $current_alienresult_folder= $alienresult_basename.$counter."/";
        if(-e $alienresult_basename.$counter."/done"){
            my $alienModelPath = $current_alienresult_folder."result.cm";
            my $alienFastaPath = $current_alienresult_folder."result.fa";
            my $alienThresholdLogFile = $current_alienresult_folder."result.log";
            if(! -e  $alienThresholdLogFile){
                print "Does not exist: $alienThresholdLogFile ";
            }
            my @alienThresholdLog;
            open(my $alienThresholdLogfh, "<", $alienThresholdLogFile)
                or die "Failed to open file: $!\n";
            while(<$alienThresholdLogfh>) {
                chomp;
                push @alienThresholdLog, $_;
            }
            close $RNAfamilyfh;
            my @alienThresholdLogSplit = split (/,/,$alienThresholdLog[0]);
            my $alienThresholdUnmodified = $alienThresholdLogSplit[2];
            my $alienThreshold = $alienThresholdUnmodified * $gathering_score_multiplier;            
            my @rfamModelNameId = split(/\s+/,$RNAfamilies[($counter - 1)]);
            my $rfamModelName = $rfamModelNameId[0];
            my $rfamModelId = $rfamModelNameId[1];
            my $rfamModelPath = $rfammodel_basename . $rfamModelId . ".cm";
            my $rfamFastaPath =$rfamfasta_basename . $rfamModelId . ".fa";
            if(! -e  $rfamModelPath){
                print "Does not exist: $rfamModelPath ";
            }
            if(! -e  $rfamFastaPath){
                print "Does not exist: $rfamFastaPath ";
            }

            if(! -e  $alienModelPath){
                print "Does not exist: $alienModelPath ";
            }
            if(! -e  $alienFastaPath){
                print "Does not exist: $alienFastaPath";
            }
            my $rfamThresholdUnmodified = $rfamModelNameId[2];
            my $rfamThreshold = $rfamThresholdUnmodified * $gathering_score_multiplier;
            #print "RNAlienStatistics -n $rfamModelName -d $rfamModelId -b $counter -i $alienModelPath -r $rfamModelPath -a $alienFastaPath -g $rfamFastaPath -t $alienThreshold -x $rfamThreshold -o $resulttempdir\n";
            $output = $output . `RNAlienStatistics -c 10 -n $rfamModelName -d $rfamModelId -b $counter -i $alienModelPath -r $rfamModelPath -a $alienFastaPath -g $rfamFastaPath -t $alienThreshold -x $rfamThreshold -o $resulttempdir`;
        }
    }
    my $outputfilePath = "/scr/kronos/egg/structuredalienseedoutput4-" . $gathering_score_multiplier . ".csv";
    open(my $outputfh, ">", $outputfilePath)
                or die "Failed to open file: $!\n";
    print $outputfh $output;
    close $outputfh;
    #$gathering_score_multiplier = 1.0;  # 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.1
    $gathering_score_multiplier = $gathering_score_multiplier - 0.1;
}
=cut
my $output;
$gathering_score_multiplier = 0.5;
for(my $counter=1; $counter <= $familyNumber; $counter++){
    my $current_alienresult_folder= $alienresult_basename.$counter."/";
    if(-e $alienresult_basename.$counter."/done"){
        my $alienModelPath = $current_alienresult_folder."result.cm";
        my $alienFastaPath = $current_alienresult_folder."result.fa";
        my $alienThresholdLogFile = $current_alienresult_folder."result.log";
        if(! -e  $alienThresholdLogFile){
            print "Does not exist: $alienThresholdLogFile ";
        }
        my @alienThresholdLog;
        open(my $alienThresholdLogfh, "<", $alienThresholdLogFile)
            or die "Failed to open file: $!\n";
        while(<$alienThresholdLogfh>) {
            chomp;
            push @alienThresholdLog, $_;
        }
        close $RNAfamilyfh;
        my @alienThresholdLogSplit = split (/,/,$alienThresholdLog[0]);
        my $alienThresholdUnmodified = $alienThresholdLogSplit[2];
        my $alienThreshold = $alienThresholdUnmodified * $gathering_score_multiplier;     
        if($alienThreshold < 40){
            $alienThreshold = 40;
        }
        my @rfamModelNameId = split(/\s+/,$RNAfamilies[($counter - 1)]);
        my $rfamModelName = $rfamModelNameId[0];
        my $rfamModelId = $rfamModelNameId[1];
        my $rfamModelPath = $rfammodel_basename . $rfamModelId . ".cm";
        my $rfamFastaPath =$rfamfasta_basename . $rfamModelId . ".fa";
        if(! -e  $rfamModelPath){
            print "Does not exist: $rfamModelPath ";
        }
        if(! -e  $rfamFastaPath){
            print "Does not exist: $rfamFastaPath ";
        }

        if(! -e  $alienModelPath){
            print "Does not exist: $alienModelPath ";
        }
        if(! -e  $alienFastaPath){
            print "Does not exist: $alienFastaPath";
        }
        my $rfamThresholdUnmodified = $rfamModelNameId[2];
        my $rfamThreshold = $rfamThresholdUnmodified * $gathering_score_multiplier;
        if($rfamThreshold < 40){
            $rfamThreshold = 40;
        }
        #print "RNAlienStatistics -n $rfamModelName -d $rfamModelId -b $counter -i $alienModelPath -r $rfamModelPath -a $alienFastaPath -g $rfamFastaPath -t $alienThreshold -x $rfamThreshold -o $resulttempdir\n";
        $output = $output . `RNAlienStatistics -c 10 -n $rfamModelName -d $rfamModelId -b $counter -i $alienModelPath -r $rfamModelPath -a $alienFastaPath -g $rfamFastaPath -t $alienThreshold -x $rfamThreshold -o $resulttempdir`;
    }
}
my $outputfilePath = "/scr/kronos/egg/structuredalienseedoutput4-0.5fixed40bit.csv";
open(my $outputfh, ">", $outputfilePath)
	or die "Failed to open file: $!\n";
print $outputfh $output;
close $outputfh;

