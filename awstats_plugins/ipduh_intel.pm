#!/usr/bin/perl
#-----------------------------------------------------------------------------
# ipduh_intel AWStats plugin
# This plugin provides:
# bouncer link (http://ipduh.com/url/bouncer) for all referering URIs        --in the 'Links from an external page' section
# decode link (http://ipduh.com/url/decode) for all referals                 --in the 'Links from an external page' section
# apropos link (http://ipduh.com/apropos) for all IPv4 or IPv6 or PTR        --in the 'Hosts' section
# dnsbl link (http://ipduh.com/ip/dnsbl) for all IPv4 addresses              --in the 'Hosts' section
#-----------------------------------------------------------------------------
# Perl Required Modules: None
# To install:
# add ipduh_intel to the AWStats Plugin Directory
# add 'LoadPlugin="ipduh_intel"' to the Plugin Section in your awstats.*.conf or the awstats.conf.local
# A simple configuration example is available at http://alog.ipduh.com/2014/12/install-debian-packaged-awstats.html
#-----------------------------------------------------------------------------
# $Revision: 1.1 $ - $Author: g0 - ipduh.com/contact $ - $Date: 1418412895 $

#use strict;
no strict "refs";

#-----------------------------------------------------------------------------
# ipduh_intel PLUGIN VARIABLES
#-----------------------------------------------------------------------------
my $PluginNeedAWStatsVersion="5.5";
my $PluginHooksFunctions="ShowInfoURL ShowInfoHost";
my $PluginName = "ipduh_intel";

#-----------------------------------------------------------------------------
# PLUGIN INIT FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_ipduh_intel {
  my $InitParams=shift;
  my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

  debug(" Plugin ipduh_intel: InitParams=$InitParams",1);

  return ($checkversion?$checkversion:"$PluginHooksFunctions");
}
#-----------------------------------------------------------------------------
sub ShowInfoURL_ipduh_intel
{
  my $param="$_[0]";
  if($param !~ /^\/.*/ )
  {
    print "<a target=_blank href=\"http://ipduh.com/url/bouncer/?$param\">bouncer</a> &nbsp; ";
    print "<a target=_blank href=\"http://ipduh.com/url/decode/?$param\">dec</a> &nbsp; ";
  }
  return 1;
}
#------------------------------------------------------------------------------
sub ShowInfoHost_ipduh_intel
{
  my $param="$_[0]";
  if($param eq '__title__' )
  {
    print "<th colspan=2><a target=_blank new href=\"http://ipduh.com\">ipduh_intel</a></th>";
  }
  elsif( $param =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/ || $param =~ /^[0-9A-F]*:/i )
  {
    if( $param =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/ )
    {
       print "<td><a target=_blank new href=\"http://ipduh.com/apropos/?$param\">apropos</a></td>";
       print "<td><a target=_blank new href=\"http://ipduh.com/ip/dnsbl/?IPin=$param\">dnsbl</a></td>";
    }
    else
    {
       print "<td colspan=2><a target=_blank new href=\"http://ipduh.com/apropos/?$param\">apropos</a></td>";
     }
  }
  else
  {
    print "<td colspan=2><a target=_blank new href=\"http://ipduh.com/apropos/?$param\">apropos</a></td>";
  }
   return 1;
}
#------------------------------------------------------------------------------
1;

