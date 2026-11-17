#!/bin/bash
echo "Iniciando PostgreSQL Server e psql..."
sudo service postgresql start
export PGPASSWORD='postgres'
psql -h 127.0.0.1 -U postgres -d dvdrental
