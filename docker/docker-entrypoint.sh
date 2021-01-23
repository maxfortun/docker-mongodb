#!/bin/sh

chown -R mongodb:mongodb /var/lib/mongodb

mongod --config /etc/mongo/mongod.conf

