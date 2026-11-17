#!/bin/bash
echo "Iniciando servidor Django..."
cd api/
source env/bin/activate
exec python dvdrental/manage.py runserver