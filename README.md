## ProjectConfigs

### Proof of concept for storing plugin configurations in separate projects

### Instructions
1. Run CreateConfiguration with a project name to have credentials and configurations stored there
1. If project name not provided, crendials and configuration will be created as usual
1. Run "Use Credentials" with a project name to show that it is working

Note: config/credential names have to be unique across all plugins because credentials are root level objects


TODO
[x] Test configProject for content, defaults to plugin
[] Remote configuration not appearing in the configuration list
[] Remote configuration not getting attached to the step
[x] Remove plugin name from credential name
