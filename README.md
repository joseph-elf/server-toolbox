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
OR
run ```install-toolbox.sh``` FROM THE TOOLBOX DIRECTORY.
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

### install-toolbox.sh
- ```install-toolbox.sh```
Add the current directory to the ```PATH```, create  ```TOOLBOX_FOLD``` variable inside ```.zshrc```, ```.bashrc``` or ```.profile``` and make all ```.sh``` executable. 
WARNING : It has to be executed from the toolbox directory !

### update-toolbox.sh
- ```update-toolbox.sh``` git pull and install new version.

### setup-python.sh
- ```setup-python.sh config.sh```

Reads ```PYTHON_VERSION``` and ```VENV_NAME``` from ```config.sh``` or ```config-server.sh``` by default.
Check if ```python```, ```python-venv```, ```python-dev```, ```python-pip``` is installed and if not install it (with a ```sudo apt install```).
After testing the environment, it create a venv in ```$HOME/&VENV_NAME``` (delete the previous one) and pip upgrade it. If you execute this command in a folder where you have a ```requirements.txt```, it pip install the packages listed in it.
You can activate the venv with ```source $VENV_PATH/bin/activate```
For more readability, most of the logs are redirected to the ```~/tmp/setup-python.log``` file.

### setup-netdata.sh
- ```setup-netdata.sh```
Install the netdata app, start and enable it. And update the existing nginx reverse proxy or create it (see setup-nginx.sh).

GENERALISE TO A MONITOR WEBSITE WHERE I CSN SEE NETDATA, AND DECIDE TO KILL PROCESSES OR RELOAD OR LAUCH SOME SMALL PYTHON SCRIPT, MAYBE A PORTABLE SSH ?

### setup-nginx.sh
- ```setup-nginx.sh```


### setup-fastapi.sh
### setup-https.sh
### setup-website.sh
## Troubleshooting
If you face problems, have recommandations, or just want to discuss, you can contact me via jelforzli.webapp@gmail.com ;) !