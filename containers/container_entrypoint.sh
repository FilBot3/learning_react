#!/usr/bin/env bash

#set -x
set -e

cp --recursive /app/* /usr/share/nginx/html

# Get an array/list of the inject_arg_ variables found.
vars=( $(grep -h -o "inject_arg_[a-zA-Z_0-9-]\+" $(find /usr/share/nginx/html -type f -name "*.js") | sort -u ) )
for var in "${vars[@]}"
do
  echo "Found: ${var}"
done

for js_file in $(find /usr/share/nginx/html -type f -name "*.js")
do
  echo "Replacing ${var} in: ${js_file}"

  for var in "${vars[@]}"
  do
    sed --in-place --expression="s|${var}|$(printenv ${var})|g" ${js_file}
  done
done

#starting nginx
nginx -g 'daemon off;'
