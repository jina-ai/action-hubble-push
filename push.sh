#!/bin/bash
sudo apt-get update && sudo apt-get install -y jq curl

GIT_TAG=$1
PUSH_DIR=$2
DOCKERFILE_GPU=Dockerfile.gpu

exit_code=1
# empty change is detected as home directory
if [ -z "$PUSH_DIR" ]
then
      echo "\$PUSH_DIR is empty"
      exit_code=0
      exit $exit_code
fi

echo pushing $PUSH_DIR
cd $PUSH_DIR

pip install yq

exec_name=`yq -r .name manifest.yml`
echo executor name is $exec_name

echo NAME=$exec_name

if [ -z "$exec_secret" ]
then
  echo no executor secret provided
  exec_secret="dummy-secret"
fi

if [ -z "$jinahub_token" ]
then
  echo no jinahub token provided
  jinahub_token="dummy-token"
fi

echo "::add-mask::$exec_secret"
echo SECRET=`head -c 3 <(echo $exec_secret)`

echo "::add-mask::$jinahub_token"
echo JINA_AUTH_TOKEN=`head -c 3 <(echo $jinahub_token)`

JINA_VERSION=$(curl -L -s "https://pypi.org/pypi/jina/json" \
  |  jq  -r '.releases | keys | .[]
    | select(contains("dev") | not)
    | select(startswith("3."))' \
  | sort -V | tail -1)
pip install git+https://github.com/jina-ai/jina.git@v${JINA_VERSION}#egg=jina[standard]

version=`jina -vf`
echo jina version $version

# we only push to a tag once,
# if it doesn't exist

# push cpu version
if [ -z "$GIT_TAG" ]
then
  echo WARNING, no git tag!
else
  echo git tag = $GIT_TAG
  jina hub pull jinahub+docker://$exec_name/$GIT_TAG
  exists=$?
  if [[ $exists == 1 ]]; then
    echo does NOT exist, pushing to latest and $GIT_TAG
    JINA_AUTH_TOKEN=$jinahub_token jina hub push --force $exec_name --secret $exec_secret . -t $GIT_TAG -t latest
    push_success=$?
    if [[ $push_success != 0 ]]; then
      echo push failed. Check error
      exit_code=1
      exit 1
    fi
  else
    echo exists, only push to latest
    JINA_AUTH_TOKEN=$jinahub_token jina hub push --force $exec_name --secret $exec_secret .
    push_success=$?
    if [[ $push_success != 0 ]]; then
      echo push failed. Check error
      exit_code=1
      exit 1
    fi
  fi
fi

# push gpu version
GIT_TAG_GPU=$GIT_TAG-gpu
if [ -z "$GIT_TAG" ]
then
  echo WARNING, no git tag!
elif [ -f $DOCKERFILE_GPU ]
then
  echo git gpu tag = $GIT_TAG_GPU
  jina hub pull jinahub+docker://$exec_name/$GIT_TAG_GPU
  exists=$?
  if [[ $exists == 1 ]]; then
    echo does NOT exist, pushing to latest and $GIT_TAG_GPU
    JINA_AUTH_TOKEN=$jinahub_token jina hub push --force $exec_name --secret $exec_secret -t $GIT_TAG_GPU -t latest-gpu -f $DOCKERFILE_GPU .
    push_success=$?
    if [[ $push_success != 0 ]]; then
      echo push failed. Check error
      exit_code=1
      exit 1
    fi
  else
    echo exists, only push to latest-gpu
    JINA_AUTH_TOKEN=$jinahub_token jina hub push --force $exec_name --secret $exec_secret -t latest-gpu -f $DOCKERFILE_GPU .
    push_success=$?
    if [[ $push_success != 0 ]]; then
      echo push failed. Check error
      exit_code=1
      exit 1
    fi
  fi
else
  echo no $DOCKERFILE_GPU, skip pushing the gpu version
fi

exit_code=0
exit $exit_code
