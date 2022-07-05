#!/bin/bash

if [ "${CONTAINER_DEBUG}" == "true" ]
then
  set -x
fi

#find /usr/share/nginx/html -type f -name "50*.html" -exec rm -f {} \;

cp --recursive /app/* /usr/share/nginx/html

# Check to see that there is a main.js file
if [ `find /usr/share/nginx/html -type f -name "*.js" -exec ls {} \; | wc -l` -gt 0 ]; then
  for js_file in `find /usr/share/nginx/html/ -type f -name "*.js"`
  do
    var=`sed -e '/.*\"\(inject_arg_[a-zA-Z_09\-]*\)\".*/!d;s//\1/' ${js_file}`
    # Check to see if var is non-zero length
    while [[ -n ${var} ]]
    do
      #Echo of variable...
      echo ${var}
      # Pulling from environment injected into container the value of variable to replace value with in main.js
      # It's kind of magic, but basically, it's looking to find a variable named whatever the value of var is and
      # assigning that value to replace.
      replace=${!var}

      if [[ -z $replace ]]
      then
          echo ${var} " will be replaced with an empty string"
      fi

      #Actual replacement with sed
      sed -i "s#\"${var}\"#\"${replace}\"#g" ${js_file}

      #checking for next variable to replace
      var=`sed -e '/.*\"\(inject_arg_[a-zA-Z_09\-]*\)\".*/!d;s//\1/' ${js_file}`
    done
  done
fi

#starting nginx
nginx -g 'daemon off;'
