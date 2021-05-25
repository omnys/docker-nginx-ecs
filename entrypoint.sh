#!/bin/bash

if [ -z "$AWS_BUCKET" ];
then 
  echo ">>> AWS_BUCKET variable not initialized."
  exit 1
fi

if [ -z "$ENVIR" ];
then 
  echo ">>> ENVIR variable not initialized."
  exit 1
fi

echo ">>> Trying to download s3://$AWS_BUCKET/$ENVIR/default.conf"
aws s3 cp s3://$AWS_BUCKET/$ENVIR/default.conf /etc/nginx/conf.d/default.conf
if [ $? -ne 0 ];
then
  echo ">>> Unable to download s3://$AWS_BUCKET/$ENVIR/default.conf"
  exit 1
fi 

#At this point we assume there are no issues with downloading objects from S3

echo ">>> Trying to download s3://$AWS_BUCKET/$ENVIR/htpasswd"
aws s3 cp s3://$AWS_BUCKET/$ENVIR/htpasswd /tmp/htpasswd
if [ $? -eq 0 ];
then
  mv /tmp/htpasswd /etc/nginx/htpasswd
fi

echo ">>> Trying to download s3://$AWS_BUCKET/$ENVIR/nginx.conf"
aws s3 cp s3://$AWS_BUCKET/$ENVIR/nginx.conf /tmp/nginx.conf
if [ $? -eq 0 ];
then
  mv /tmp/htpasswd /etc/nginx/nginx.conf
fi

if [ -n "$WITHSSL" ] && [ $WITHSSL == "true" ];
then
  echo ">>> Trying to generate ssl certificates"
  openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=IT/ST=IT/L=Rome/O=IT/CN=www.example.com" -keyout /etc/nginx/ssl.key -out /etc/nginx/ssl.crt
  if [ $? -ne 0 ];
  then
    echo ">>> Error generating ssl certificate"
    exit 1
  fi
fi

exec "$@"
