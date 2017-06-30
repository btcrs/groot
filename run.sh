#!/bin/bash

command=$1
runner=$2
params=$3

CONTAINER_NAME=versioning
docker stop ${CONTAINER_NAME}
docker rm ${CONTAINER_NAME}
docker build -t ${CONTAINER_NAME} .

if [[ ${command} == makedocs ]]; then
  docker run --rm -d --name=${CONTAINER_NAME} -p 8000:8000 -v `pwd`:/code -w /code/docs ${CONTAINER_NAME} make html
  git add -A
  git commit -m "Generated gh-pages for `git log master -1 --pretty=short --abbrev-commit`" && git push origin gh-pages ; git checkout master
elif [[ ${command} == run ]]; then
  docker run --rm -it --name=${CONTAINER_NAME} -p 8000:8000 -v `pwd`/app:/code -w /code ${CONTAINER_NAME} python manage.py ${runner} ${params}
elif [[ ${command} == runserver ]]; then
  docker run --rm -it --name=${CONTAINER_NAME} -p 8000:8000 -v `pwd`/app:/code -w /code ${CONTAINER_NAME} python manage.py runserver [::]:8000
else
  docker run --rm -it --name=${CONTAINER_NAME} -p 8000:8000 -v `pwd`/app:/code -w /git_code/app ${CONTAINER_NAME} python manage.py runserver [::]:8000
fi
