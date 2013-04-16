#!/usr/bin/perl
use strict;
use warnings;
use 5.010;

use Cwd            qw(abs_path);
use Data::Dumper   qw(Dumper);
use File::Basename qw(basename dirname);

# list drafts  TODO: list them  sorted by =timstamp
# TODO: check the =status of the pages
# TODO: check how many pages have been translated in each language
# TODO: list the translated pages without =original or without =translator entry

my $root = dirname dirname abs_path $0;

my @languages = map { basename $_ } glob "$root/sites/*";
#say Dumper \@languages;

say "\nList items in DONE folder";
say '-' x 30;
foreach my $lang (@languages) {
	my @drafts = map { basename $_ } glob "$root/sites/$lang/done/*.tt";
	next if not @drafts;
	say "Language $lang";
	say "   $_" for @drafts;
}
say "\nList items in DRAFT folder";
say '-' x 30;
foreach my $lang (@languages) {
	my @drafts = map { basename $_ } glob "$root/sites/$lang/drafts/*.tt";
	next if not @drafts;
	say "Language $lang";
	say "   $_" for @drafts;
}

# collect all the english pages
say "\nList of PAGES";
say '-' x 30;
my %META_PAGE = map { $_ => 1 } qw(index.tt about.tt keywords.tt archive.tt products.tt);
{
	my %english = map { substr(basename($_), 0, -3), 1 } glob "$root/sites/en/pages/*.tt";
	foreach my $lang (@languages) {
		next if $lang eq 'en';
		my @pages = glob "$root/sites/$lang/pages/*.tt";
		next if not @pages;
		foreach my $file (@pages) {
			next if $META_PAGE{ basename $file };
			open my $fh, '<', $file or die "Could not open '$file' $!";
			my $original;
			my $translator;
			while (my $line = <$fh>) {
				chomp $line;
				if ($line =~ /^=original\s+(\S+)/) {
					$original = $1;
				}
				if ($line =~ /^=translator\s+(\S+)/) {
					$translator = $1;
				}
			}
			close $fh;
			if (not defined $original) {
				printf "File %-100s does not have an =original entry\n", $file;
			} elsif (not $english{$original}) {
				printf "File %-100s has =original entry '%s' which does not exist in the English version\n", $file, $original;
			}
			if (not defined $translator) {
				printf "File %-100s does not have a =translator entry\n", $file;
			}
		}
	}
}

