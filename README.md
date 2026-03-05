# SERVER-TOOLBOX
## Presentation of the tool
This small repository contain a set of tool very practical to setup a remote server like VPS, aws EC2, Google Cloud Engine, etc for your developpment project.
I usually use it to initialize EC2 instances and send and execute some heavy code. I also use it to set up my personnal server running some API use on my personnal website


## Installation
Simply git clone this repository.
```git clone repo```
 We recommand to add the repository to your ```PATH``` variable 
``` PATH```
and to make all bash command executable with
```chmod +x repo/*.sh```.
You can now run the following bash commands...

## Features
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

Reads ```IP```, ```USERNAME```, ```SSH_KEY```, ```GIT_HUB_servertoolbox``` and ```GIT_HUB_repos``` from ```config.sh``` or ```config-server.sh``` by default. 
Send the config file to the server using ```scp```.
Then connects by ```ssh``` to the server and run some initialisation commands:
    - clone the repository ```GIT_HUB_servertoolbox``` containing this toolbox, add it to the ```PATH``` and make ```*.sh``` executable
    - clone all repositories in ```GIT_HUB_repos```



### connect-server.sh
- ```connect-server.sh config.sh```

Reads ```IP```, ```USERNAME``` and ```SSH_KEY``` from ```config.sh``` or ```config-server.sh``` by default, and connects by ```ssh``` to the server.



### setup-nginx.sh
### setup-netdata.sh
### setup-python.sh
### setup-fastapi.sh
### setup-https.sh
### setup-website.sh

## Troubleshooting
If you face problems, have recommandations, or just want to discuss, you can contact me via jelforzli.webapp@gmail.com ;) !