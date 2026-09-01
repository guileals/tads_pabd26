#!/bin/bash
echo "Iniciando psql..."
sudo service postgresql start
psql -h 127.0.0.1 -U admin -d pabd