#!/bin/bash
set -ex

sudo apt-get update && sudo apt-get install -y jq curl

JINA_VERSION=$(curl -L -s "https://pypi.org/pypi/jina/json" \
  |  jq  -r '.releases | keys | .[]
    | select(contains("dev") | not)
    | select(startswith("2."))' \
  | sort -V | tail -1)
pip install git+https://github.com/jina-ai/jina.git@v${JINA_VERSION}#egg=jina[standard]

GIT_TAG=$1
PUSH_DIR=$2

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

version=`jina -vf`
echo jina version $version

echo "::add-mask::$exec_uuid"
echo UUID=`head -c 3 <(echo $exec_uuid)`

echo "::add-mask::$exec_secret"
echo SECRET=`head -c 3 <(echo $exec_secret)`

# we only push to a tag once,
# if it doesn't exist
echo git tag = $GIT_TAG

if [ -z "$GIT_TAG" ]
then
  echo WARNING, no git tag!
else
  echo git tag = $GIT_TAG
  jina hub pull jinahub+docker://$exec_name/$GIT_TAG
  exists=$?
  if [[ $exists == 1 ]]; then
    echo does NOT exist, pushing to latest and $GIT_TAG
    jina hub push --force $exec_uuid --secret $exec_secret . -t $GIT_TAG -t latest
  else
    echo exists, only push to latest
    jina hub push --force $exec_uuid --secret $exec_secret .
  fi
fi

exit_code=0
exit $exit_code
