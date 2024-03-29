#
#  Copyright 2016 Electric Cloud, Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

#########################
## createcfg.pl
#########################

use ElectricCommander;
use ElectricCommander::PropDB;
use Data::Dumper;

use constant {
               SUCCESS => 0,
               ERROR   => 1,
             };

my $opts;

## get an EC object
my $ec = new ElectricCommander();
$ec->abortOnError(0);

## load option list from procedure parameters
my $x       = $ec->getJobDetails($ENV{COMMANDER_JOBID});
my $nodeset = $x->find('//actualParameter');
foreach my $node ($nodeset->get_nodelist) {
    my $parm = $node->findvalue('actualParameterName');
    my $val  = $node->findvalue('value');
    $opts->{$parm} = "$val";
}

if (!defined $opts->{config} || "$opts->{config}" eq "") {
    print "config parameter must exist and be non-blank\n";
    exit ERROR;
}

# check to see if a config with this name already exists before we do anything else
my $configPath;
my $configName;
my $targetProject = $opts->{configProject};
if ($targetProject =~ /^ *$/) {
	$configPath = "/myProject/ec_plugin_cfgs";
	$configName = $opts->{config};
} else {
	$configPath = "/projects/$targetProject/pluginConfigs/$[/myProject/pluginKey]";
	$configName = "$opts->{config}";
}

my $xpath    = $ec->getProperty("$configPath/$configName");
my $property = $xpath->findvalue("//response/property/propertyName");

if (defined $property && "$property" ne "") {
    my $errMsg = "A configuration named '$configName' already exists.";
    $ec->setProperty("/myJob/configError", $errMsg);
    print $errMsg;
    exit ERROR;
}

print "Config Path: " . $configPath . "\n";
my $cfg = new ElectricCommander::PropDB($ec, $configPath);
my $errors = $ec->checkAllErrors($xpath);

# add all the options as properties
foreach my $key (keys %{$opts}) {
    if ("$key" eq "config") {
        next;
    }
	$xpath    = $cfg->setCol("$opts->{config}", "$key", "$opts->{$key}");
}

exit SUCCESS;
