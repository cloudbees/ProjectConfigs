# /projects/Default/credentials/ProjectConfig_Remote
ectool getFullCredential "$[/javascript
		myJob.configProject
			?"/projects/" + myJob.configProject + "/credentials/" + myJob.config
			:myJob.config
	]" --value userName
