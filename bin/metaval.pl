#!/usr/bin/perl

# Expands variables according to a "meta" file, which
# contains GNU make variable assignments.  Ordinarily,
# values are single-line strings, but a multi-line string
# will be indicated by a final \ at the end of each line
# before the last.
#
# Usage 1:
#    metaval meta var1 var2
#
#    This just prints the value of each var, one per line,
#    according to the meta file.  The variable names are *not*
#    printed.
#
# Usage 2:
#    metaval meta LISTALL
#
#    Prints ALL var/val pairs, one per line, in var<TAB>val format.
#
# Usage 3:
#    metaval meta < file.tem > file
#
#    This is a filter that replaces strings like $(var)
#    with their values.  It treats file.tem as one big
#    variable to be expanded, and prints it.
#
# Because we use make to do all the expansions, funny
# messages will result if:
#
# - in usage 1, a variable is mentioned twice on the cmd line.
# - in usage 1, a variable is mentioned that is not defined in the meta file.
# - in usage 3, file.tem contains a line "endef".

die "Usage: See $0." unless @ARGV;
my $meta = shift(@ARGV);
if (@ARGV) {

  # usages 1, 2.
  system("make --warn-undefined-variables -f $ENV{ACLPUB}/make/Makefile_metaval META=$meta @ARGV")==0 || die "The variables mentioned above need to be defined in the file \"$meta\".\n";

} else {

  # usage 3.  Our trick here is to pass stdin to make as the value of
  # a variable INPUTTEXT, and then expand it like any other.  An
  # alternative would be to get a var/val table via usage 2, and then
  # use Perl substitutions to expand stdin ourselves.
  #
  # This trick requires a couple of other tricks.  We add a space to
  # the end of every line of stdin, so that make won't see any
  # line-final backslashes from file.tem, to which it always gives a
  # special interpretation.  (These might actually show up in file.tem
  # because of latex \\.)  We get rid of this space in the output;
  # note that it will only appear at the end of original lines, not
  # new lines created by substituting a multiline variable.  We also
  # get rid of the \ that our makefile prints by policy at the end of
  # each non-final line of the output (an alternative would be to have
  # a makefile switch saying not to print that).

  open(MAKE,"| make --warn-undefined-variables -f - META=$meta INPUTTEXT | perl -pe 's/( )?(\\\\)?\$//'");  # print $(INPUTTEXT), but remove final space and/or backslash from each line
  print MAKE "define INPUTTEXT\n";
  while (<>) { s/$/ /; print MAKE; }   # add final space
  print MAKE "endef\n";
  print MAKE "include $ENV{ACLPUB}/make/Makefile_metaval\n";
  close(MAKE);
}
