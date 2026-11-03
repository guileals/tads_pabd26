# CONFIGURANDO BACKEND COM DJANGO REST

## Criar env

```bash
mkdir api
cd api
sudo apt update
sudo apt install python3
python -m pip install --upgrade pip
python3 -m venv env
source env/bin/activate
```

## Criar novo projeto Django

```bash
pip install django
django-admin startproject dvdrental
cd dvdrental
```

## Instalar dependências

```bash
python -m pip install -r requirements.txt
```

## Crie um novo aplicativo dentro do projeto

```bash
python manage.py startapp backend
```

## Adicione o aplicativo ao INSTALLED_APPS no arquivo dvdrental/settings.py

```python
INSTALLED_APPS = [
    ...
    'backend',
]
```

## Configure o banco de dados PostgreSQL no arquivo dvdrental/settings.py

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'dvdrental',
        'USER': 'postgres',
        'PASSWORD': 'postgres',
        'HOST': '127.0.0.1',
        'PORT': '5432',
    }
}
```

## Verificar a conexão com o banco de dados

```bash
python manage.py shell
```

No shell:

```python
from django.db import connection
with connection.cursor() as cursor:
    cursor.execute("SELECT current_database(), current_user, version()")
    print(cursor.fetchone())
```

Para fechar o shell: CTRL + D

## Mapear o banco existente

Cuidado! Revise e reorganize o arquivo `models.py`

```bash
python manage.py inspectdb > backend/models.py
```

## Migrations

```bash
python manage.py makemigrations dvdrental
python manage.py migrate
python manage.py check
```

## Configurar o `settings.py` para a API

No arquivo `dvdrental/settings.py`, adicione o Django REST Framework e o
`drf-spectacular` à lista `INSTALLED_APPS`:

```python
INSTALLED_APPS = [
    # Aplicativos padrão do Django...
    'backend',
    'rest_framework',
    'drf_spectacular',
]
```

Configure o gerador do schema OpenAPI e as informações exibidas na documentação:

```python
REST_FRAMEWORK = {
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
}

SPECTACULAR_SETTINGS = {
    'TITLE': 'DVD Rental API',
    'DESCRIPTION': 'API somente para leitura do banco DVD Rental.',
    'VERSION': '1.0.0',
}
```

Essas configurações pressupõem que `djangorestframework` e `drf-spectacular`
estejam instalados pelo `requirements.txt`.

## Testar a API

Inicie o servidor a partir da pasta `api/dvdrental`:

```bash
python -m pip install -r requirements.txt
python manage.py runserver
```

- Abra `http://127.0.0.1:8000/api/docs/` para explorar e testar os endpoints.
- O schema OpenAPI fica em `/api/schema/`.
- Os endpoints são somente de leitura (`GET`); 
- Todos os models registrados em `backend/models.py` têm uma rota de listagem sob `/api/`.
