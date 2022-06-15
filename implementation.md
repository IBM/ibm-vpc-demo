
# Implementation
## TLDR
```
cp template.local.env local.env
vi local.env
source local.env
```

- 000-prerequisites.sh
- 010-create.sh
- 800-test.sh - see notes below for pytest set up
- 900-cleanup.sh

The observability configuration is optional.  To collect data you must create the observability instances manually.  See below

## Configure general
See the local.env file created for the kind of parameterization.  Most configuration is self explanatory.  A few extra notes:

- TF_VAR_postgresql, optional, default true, can be set to false to remove database creation.  Test output will mark tests as expected failures:

## Configure observability for journey v2
[v2/journey](vs/journey.md) is all about observability.  The region in which the terraform resources are provisioned must also have:
- logging for platform
- monitoring for platform
- activity tracker

TODO - see TF_VAR_observability

The environment variables:
- TF_VAR_sysdig_ingestion_key - create a sysdig instance and fill this in from the GUI
- TF_VAR_logdna_ingestion_key - create a logdna instance and fill this in from the GUI.


000-prerequsites.sh will verify that the platform logging is also availble if the ingestion key is set, same with monitoring.  If both environment variables are set, then AT should exist as well:
- if both TF_VAR_sysdig_ingestion_key and TF_VAR_logdna_ingestion_key are set create an AT instance in the region

## .travis.yml
In the [.travis.yml](.travis.yml) you will notice the script config.  Here is a portion:
```
  docker run -i --volume $PWD:/root/mnt/home --workdir /root/mnt/home \
    --env TRAVIS=true \
    --env TF_VAR_ibmcloud_api_key \
    --env TF_VAR_region \
    --env TF_VAR_postgresql \
    --env TF_VAR_basename=travis-3tier-$TRAVIS_JOB_ID \
    --env TF_VAR_resource_group_name=3tier \
    ...
```
Notice some of the environment variables do not have values assigned.  These can be assigned in the travis configuration.

- TF_VAR_ibmcloud_api_key - required
- TF_VAR_region - defaults to us-south
- TF_VAR_postgresql - defaults to true

Postgreql instances should not be created/destroyed more then 1/day.  It is expensive for IBM.  But the vpc resources - no problem.  So set TF_VAR_postgresql=false and run it continuously if you wish.

## IAM API key
The directory api/ contains the terraform to create an api key for this use case.  If you are configuring travis use this to create the api key and copy it into the travis configuration.  Avoid using a personal api key

## testing
Pytest is used to run the test suite.  See [test/test.md](test/test.md) for pytest information.  It tests the front end and back end after they have been deployed.

## Create resources
The vpc_tf directory has a terraform implementation of the 3 tier architecture.  The 010-create.sh script initializes the directory and calls `terraform apply`.  The files in vpc_tf/:
- vpc.tf - vpc resources like subnets and instance a
- resources.tf - postgresql creation
- user_data.sh - script to create the systemctl service from a python3 program.  Note that the application example in the app/ directory is referenced.  See [application](application.md) for a full description.

## Application

See [application](application.md) for a description of how to deploy and test.
The files in the app/ are for a python application that returns json from the api:
- / - uname and ip address information dict(uname="vpc3tier-front-0", floatin_ip="52.118.144.159",private_ip="10.0.0.5")
- /increment - {"uname":"vpc3tier-back-0","floatin_ip":"169.48.154.27","private_ip":"10.0.1.5","count":2} - same as / but add a count of the times this instance has been called.  When called on a front instance a "remote" key will contain the back values {"uname":"vpc3tier-front-0","floatin_ip":"52.118.144.159","private_ip":"10.0.0.5","count":10,"postgresql":"no postgresql configured","remote":{"uname":"vpc3tier-back-0","floatin_ip":"169.48.154.27","private_ip":"10.0.1.5","count":21,"postgresql":{"count":3}}}
- /postgresql - same as increment but a counter will also be kept in the database of the total times the database is incremented.  Only the back instances are configured for postgresql

### Running the app/ on your desktop

- cd app
- verify you have a python3 environment with pip, that you are willing to install more packages.  I use [pyenv](https://github.com/pyenv/pyenv) to install the desired version of python and then make a python virtual environment. zsh:
```
function venv() {
  if [[ ! -d venv ]]; then
    c="python -m venv venv --prompt ${PWD:t}"
    echo $c - $(python --version)
    eval $c
    source venv/bin/activate
    pip install --upgrade pip
  else
    source venv/bin/activate
  fi
}
$ venv
```
- pip3 install fastapi uvicorn psycopg2-binary pytest
- python3 main.py
- curl localhost:8000/
- curl localhost:8000/increment
- curl localhost:8000/postgresql

Environment variables:

- REMOTE_URL - Both the /increment and /postgesql will generate the local data but also call a REMOTE_URL if the environment variable is present.  Just provide the string like "http://localhost:8001".  A floating ip or load balancer DNS address can be set as well.

The PORT environment variable will be used to listen for http requests.  if not set the default is 8000.

### Application in docker
```
cd app
docker run -it -v $(pwd):/home -p 8000:8000 python sh
# in docker container:
cd /home
pip3 install fastapi uvicorn psycopg2-binary
python3 main.py
```

I have not connected two docker containers together to test the REMOTE_URL.

## Postgresql
If the postgresql.py module file is placed next to the main.py file then it will be used to create a table in a postgresql database and keep a counter in the first row of the table.

The create scripts will use terraform to create an instance of a postgresql database and also create a terraform_service_credentials.json file.  You should see it in the app/ directory after the 010-create.sh script completes.

A normal service credential file is in a different format and used as well:
- open the database in the cloud console and open the **Service credentials** tab on the left
- click the **New credential** 
- click the copy button and paste the contents into a file named **service_credentials.json** next to main.py.  Notice the different name for the normal json file versus the terraform created json file.

This is what I see:
```
$ ls
main.py                  postgresql.py            service_credentials.json OTHERSTUFF
```