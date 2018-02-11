#!/usr/bin/perl

#kana/kanji-romaji converter

use utf8;
use Text::Kakasi;
use Encode;
require Encode::Detect;

sub kakasi {
	my $k = Text::Kakasi->new('-Ha', '-Ka', '-Ja', '-Ea', '-ga', '-ka', '-s');
	my $in = join("", <STDIN>);
	my $utf8 = decode("Detect", $in);
	$utf8 =~ s/\N{U+FF5E}/~/gi;
	my $euc = encode("euc-jp", $utf8);
	return $k->get($euc);
}

sub edit {
	my $str = shift;
	my $list = "a:ā,i:ī,u:ū,e:ē,o:ō";
	my %hash = map {split(/:/, $_)} split(/,/, $list);
	$$str =~ s/(a|i|u|e|o)(\1+)/$1\^/g;
	while ($$str =~ /(a|i|u|e|o)\^/) {
		foreach my $exp (1..$#-) {
			my $y = substr $$str, $-[$exp], 1;
			$$str =~ s/.\^/$hash{$y}/;
		}
	}
	$$str =~ s/(\(|\[|\{|\:)\h/$1/g;
	$$str =~ s/\h(\!|\,|\.|\:|\;|\?|\%|\)|\]|\})/$1/g;
	while ($$str =~ /(\!|\,|\.|\:|\;|\?|\%|\)|\]|\})[^\s\d,.:]/g) {
		my $y = substr $$str, $-[0], 1;
		substr $$str, $-[0], 1, $y . " ";
	}
	return encode_utf8($$str);
}

sub usage {
	print "Usage: <input> | kakaro\n";
	exit(1);
}

sub run {
	if (-t STDIN) {
		usage();
	} 
	else {
		my $str = kakasi();
		print edit(\$str);
		
	}
}

run();
