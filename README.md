### utils.sh
This contain several utilitary function to open and checks configs:
- ``` print_variable name```
This print the variable ``` &name```. It call handle array and throw a warning when the value is not set

- ``` check_variable name -rv```
Check if the variable ```&name``` is defined (more general than set).
    - ```-v``` : verbose the variable calling the ``` print_variable``` function. 
    - ```-r``` : required, throw an error if the variable doesn't exist (return 1) and exit.

- ```load_config_and_check -c config.sh -vr IP HOST ...```
load a config file containing variable definition and check the list of variables with ```check_variable``` written as argument. Throw an error if the configuration file is not found. Throw error depending on ```check_variable``` flags.
    - ```-c config.sh``` : config file to open, by default open ```config-server.sh```
    - ```-vr``` : flag to pass to ```check_variable```
    - ```IP HOST ...``` : list of variables to check

### init-server.sh
- ```init-server.sh config.sh```
Reads ```IP```, ```USERNAME```, ```SSH_KEY```, ```GIT_HUB_servertoolbox``` and ```GIT_HUB_repos``` from ```config.sh``` or ```config-server.sh``` by default. Then connects by ```ssh``` to the server and run some initialisation commands:
    - dji
### connect-server.sh
- ```connect-server.sh config.sh```
Reads ```IP```, ```USERNAME``` and ```SSH_KEY``` from ```config.sh``` or ```config-server.sh``` by default, and connects by ```ssh``` to the server.
