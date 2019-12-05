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

##########################
# createAndAttachCredential.pl
##########################
use ElectricCommander;
use JSON;
use Data::Dumper;

use constant {
	SUCCESS => 0,
	ERROR   => 1,
};

## get an EC object
my $ec = new ElectricCommander();
$ec->abortOnError(0);

my $credName;

my $xpath = $ec->getFullCredential("credential");
my $errors = $ec->checkAllErrors($xpath);
my $clientID = $xpath->findvalue("//userName");
my $clientSecret = $xpath->findvalue("//password");


my $configPath;
my $projName;
my $fullCredPath;
my $targetProject = "$[/myJob/configProject]";
if ($targetProject =~ /^ *$/) {
	$configPath = "/myProject/ec_plugin_cfgs";
	$projName = "$[/myProject/projectName]";
	$credName = "$[/myJob/config]";
	$fullCredPath = $credName;
} else {
	$configPath = "/projects/$targetProject/pluginConfigs/$[/myProject/pluginKey]";
	$projName = $targetProject;
	$credName = "$[/myJob/config]";
	# /projects/Default/pluginConfigs/ProjectConfig_Remote
	$fullCredPath = "/projects/$projName/credentials/$credName";
}

# Create credential
$ec->deleteCredential($projName, $credName);
$xpath = $ec->createCredential($projName, $credName, $clientID, $clientSecret);
$errors .= $ec->checkAllErrors($xpath);

# Give config the credential's real name
my $fullConfigPath = "$configPath/$[/myJob/config]";
$xpath = $ec->setProperty($fullConfigPath . "/credential", $credName);
$errors .= $ec->checkAllErrors($xpath);

# Give job launcher full permissions on the credential
my $user = '$[/myJob/launchedByUser]';
$xpath = $ec->createAclEntry("user", $user,
    {projectName => $projName,
     credentialName => $credName,
     readPrivilege => allow,
     modifyPrivilege => allow,
     executePrivilege => allow,
     changePermissionsPrivilege => allow});
$errors .= $ec->checkAllErrors($xpath);

# Attach credential to steps that will need it
my $stepsJSON = $ec->getPropertyValue("/myProject/procedures/CreateConfiguration/ec_stepsWithAttachedCredentials");
if (defined $stepsJSON && "$stepsJSON" ne "") {
	#parse as json
	my $steps = from_json($stepsJSON);
    foreach my $step( @$steps ) { 
		print "Attaching credential to procedure " . $step->{procedureName} . " at step " . $step->{stepName} . "\n";
		my $apath = $ec->attachCredential("$[/myProject]", $fullCredPath,
										{procedureName => $step->{procedureName},
											stepName => $step->{stepName}});
		$errors .= $ec->checkAllErrors($apath);
	}
}

if ("$errors" ne "") {
    # Cleanup the partially created configuration we just created
    $ec->deleteProperty($fullConfigPath);
    $ec->deleteCredential($projName, $credName);
    my $errMsg = "Error creating configuration credential: " . $errors;
    $ec->setProperty("/myJob/configError", $errMsg);
    print $errMsg;
    exit 1;
}
