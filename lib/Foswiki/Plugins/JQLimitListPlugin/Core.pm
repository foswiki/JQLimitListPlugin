# Extension for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# JQLimitListPlugin is Copyright (C) 2021-2024 Michael Daum http://michaeldaumconsulting.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details, published at
# http://www.gnu.org/copyleft/gpl.html

package Foswiki::Plugins::JQLimitListPlugin::Core;

use strict;
use warnings;

use Foswiki::Func ();
use Foswiki::Plugins::JQueryPlugin::Plugin ();
use Foswiki::Plugins::JQLimitListPlugin ();
use JSON ();

our @ISA = qw( Foswiki::Plugins::JQueryPlugin::Plugin );

sub new {
  my $class = shift;

  my $this = bless(
    $class->SUPER::new(
      name => 'LimitList',
      version => $Foswiki::Plugins::JQLimitListPlugin::VERSION,
      author => 'Michael Daum',
      homepage => 'http://foswiki.org/Extensions/JQLimitListPlugin',
      javascript => ['limitList.js'],
      #css => ['limitList.css'],
      puburl => '%PUBURLPATH%/%SYSTEMWEB%/JQLimitListPlugin',
    ),
    $class
  );

  return $this;
}

sub DESTROY {
  my $this = shift;

  undef $this->{_json};
}

sub init {
  my $this = shift;

  $this->SUPER::init();
  my $id = $this->{idPrefix} . '::' . uc($this->{name});
  Foswiki::Func::addToZone("head", $id, '<style>.jqLimitList{display:none}.jqLimitList.inited{display:inline}</style>');
}

sub LIMITLIST {
  my ($this, $session, $params, $topic, $web) = @_;

  my $text = $params->{text} // $params->{_DEFAULT} // "";
  $text = Foswiki::Func::decodeFormatTokens($text);
  $text = Foswiki::Func::expandCommonVariables($text, $topic, $web) if $text =~ /%/;

  my $split = $params->{split};
  my $sep = $params->{separator} // ', ';
  my $format = $params->{format} // '<span>$1</span>';

  if ($split) {
    $text = join($sep, map { my $tmp =$format; $tmp =~ s/\$1/$_/g; $tmp} split(/$split/, $text));
  }

  my @htmlData = ();
  foreach my $key (sort keys %$params) {
    next if $key eq '_DEFAULT';
    next if $key eq '_RAW';
    next if $key eq 'text';
    my $val = $params->{$key};
    next unless $val;
    $key = lc(Foswiki::spaceOutWikiWord($key, "-"));
    $key =~ s/_/-/g;
    push @htmlData,  $this->formatHtmlData($key, $val);
  }

  return '<div class="jqLimitList" '.join(" ", @htmlData). ">$text</div>";
}

sub formatHtmlData {
  my ($this, $key, $val) = @_;

  if (ref($val)) {
    $val = $this->json->encode($val);
  } else {
    $val = _entityEncode($val);
  }

  return "data-$key='$val'";
}

sub json {
  my $this = shift;

  unless (defined $this->{_json}) {
    $this->{_json} = JSON->new->allow_nonref(1);
  }

  return $this->{_json};
}

sub _entityEncode {
  my $text = shift;

  $text =~ s/([[\x01-\x09\x0b\x0c\x0e-\x1f"%&\$'*<=>@\]_])/'&#'.ord($1).';'/ge;
  return $text;
}

1;
