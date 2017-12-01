#!/bin/bash

if [ "${USER}" != "root" ]; then
    adduser -D -u ${UID} -h /code ${USER}
    su ${USER} -c /bin/sh
else
    su -c /bin/sh
fi
