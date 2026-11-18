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

***

# Autenticação JWT e permissões na API

> **Estado atual:** a API ainda não configura JWT nem classes de permissão do
> Django REST Framework. Portanto, antes de seguir este tutorial, suas rotas
> `/api/` não exigem autenticação. Os passos abaixo mostram como habilitar
> JWT e controlar o acesso às tabelas **pela API**.

As permissões do Django controlam as requisições HTTP à API; elas não alteram
as permissões SQL do PostgreSQL. Como o projeto configura o Django para
conectar ao banco como `postgres`, um superusuário, não use essa conta em
produção. JWT também não substitui uma configuração segura de `SECRET_KEY`,
`DEBUG` e credenciais do banco.

## 1. Instalar o Simple JWT

Instale as dependências no ambiente virtual, a partir de `api/dvdrental/`:

```bash
pip install djangorestframework-simplejwt
```

## 2. Configurar autenticação e permissões

Em `api/dvdrental/dvdrental/settings.py`, mantenha o `DEFAULT_SCHEMA_CLASS`
existente e configure `REST_FRAMEWORK` assim:

```python
REST_FRAMEWORK = {
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
        'rest_framework.permissions.DjangoModelPermissions',
    ],
}
```

Com essa configuração, uma rota exige um token válido **e** a permissão
Django correspondente ao modelo consultado.

## 3. Adicionar as rotas para obter e renovar tokens

Em `api/dvdrental/dvdrental/urls.py`, importe as views do Simple JWT:

```python
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)
```

Adicione estas rotas à lista `urlpatterns`:

```python
path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
```

Os endpoints do schema e da documentação Swagger também passam a seguir
as permissões padrão do DRF. Se quiser mantê-los públicos, importe
`AllowAny` e passe `permission_classes=[AllowAny]` às três views em
`urlpatterns`. Por exemplo:

```python
from rest_framework.permissions import AllowAny

path(
    'api/schema/',
    SpectacularAPIView.as_view(permission_classes=[AllowAny]),
    name='schema',
),
path(
    'api/docs/',
    SpectacularSwaggerView.as_view(
        url_name='schema',
        permission_classes=[AllowAny],
    ),
    name='swagger-ui',
),
```

Isso não torna as rotas de dados públicas.

## 4. Criar as permissões no banco

Execute as migrações para criar as tabelas de autenticação e as permissões padrão dos modelos:

```bash
python manage.py check
python manage.py migrate
```

### Criar um administrador - inserir email e senha (min. 8 caractéres)

```bash
python manage.py createsuperuser
```
<!-- 
    username: pabd2026
    email: pabd2026@tads.ifrn
    Senha: tadspabd
-->

### Criar um usuário comum

Execute `python manage.py shell`:

```python
from getpass import getpass
from django.contrib.auth import get_user_model

User = get_user_model()

usuario = User.objects.create_user(
    username="alunopabd",
    password=getpass("Senha: "), #aluno2026
    first_name="Ana",
    last_name="Silva",
    email="ana@tads.ifrn",
)

print(usuario.username)
print(usuario.is_staff)
```

## 5. Tempo de validade dos tokens

Em `api/dvdrental/dvdrental/settings.py`, adicione:

```python
from datetime import timedelta

SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=15),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=1),
    "AUTH_HEADER_TYPES": ("Bearer",),
}
```

Access token: usado para acessar os endpoints protegidos.
Refresh token: usado para solicitar um novo access token.
O refresh token não deve ser colado no campo de autorização do Swagger.

## 6. Configuração do Swagger

Em `api/dvdrental/dvdrental/settings.py`:

```python
SPECTACULAR_SETTINGS = {
    "TITLE": "DVD Rental API",
    "DESCRIPTION": "API para o banco DVD Rental.",
    "VERSION": "1.0.0",
    "SERVE_INCLUDE_SCHEMA": False,
    "COMPONENT_SPLIT_REQUEST": True,
    "SWAGGER_UI_SETTINGS": {
        "deepLinking": True,
        "persistAuthorization": False,
    },
}
```

## 7. Criar um endpoint de perfil

Esse endpoint permitirá verificar qual usuário foi reconhecido pelo token. Alteração em `backend/serializers.py`. Mantenha os serializers existentes e acrescente:

```python
from django.contrib.auth import get_user_model

User = get_user_model()

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = (
            "id",
            "username",
            "first_name",
            "last_name",
            "email",
        )
        read_only_fields = fields
```

Esse exemplo utiliza os campos do usuário padrão do Django. Se já houver um usuário personalizado, ajuste os campos ao modelo real. Não inclua o campo de senha na resposta do perfil.

Alteração em `backend/views.py`:

```python
from rest_framework.generics import RetrieveAPIView
from rest_framework.permissions import IsAuthenticated

class UserProfileView(RetrieveAPIView):
    serializer_class = serializers.UserProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user
```

## 8. Adicionar as rotas JWT

Adicione os imports em `backend/urls.py`:

```python
from django.urls import path

from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)
```

Substituir `urlpatterns` por:

```python
urlpatterns = [
    path(
        "auth/token/",
        TokenObtainPairView.as_view(),
        name="token_obtain_pair",
    ),
    path(
        "auth/token/refresh/",
        TokenRefreshView.as_view(),
        name="token_refresh",
    ),
    path(
        "auth/token/verify/",
        TokenVerifyView.as_view(),
        name="token_verify",
    ),
    path(
        "auth/me/",
        views.UserProfileView.as_view(),
        name="user_profile",
    ),
] + router.urls
```

## 9. Proteger as operações existentes

Com a permissão global `IsAuthenticated`, a proposta é exigir JWT nos ViewSets que não tenham configurações locais substituindo essa regra. Ajuste em `backend/views.py`:

```python
from rest_framework.permissions import IsAuthenticated

class ReadOnlyListViewSet(
    mixins.ListModelMixin,
    viewsets.GenericViewSet,
):
    pagination_class = None
    permission_classes = [IsAuthenticated]
```

Se quiser permitir acesso somente a algumas tabelas, adicione no ViewSet:

```python
from rest_framework.permissions import AllowAny

class ActorViewSet(ReadOnlyListViewSet):
    permission_classes = [AllowAny]
    queryset = models.Actor.objects.all()
    serializer_class = serializers.ActorSerializer


class FilmViewSet(ReadOnlyListViewSet):
    permission_classes = [AllowAny]
    queryset = models.Film.objects.all()
    serializer_class = serializers.FilmSerializer
```

## 10. Documentar o corpo do registro

No projeto, a action `register` utiliza `RegisterRentalSerializer` para validar a entrada. Para que o Swagger apresente os campos corretos, documente explicitamente o request dessa action, no arquivo `backend/views.py`:

```python
from drf_spectacular.utils import (
    OpenApiResponse,
    extend_schema,
)

# Adicione antes do @action
@extend_schema(
        request=serializers.RegisterRentalSerializer,
        responses={
            201: OpenApiResponse(
                description=(
                    "Aluguel e pagamento registrados."
                ),
            ),
        },
    )
```

O decorador `extend_schema` permite especificar serializers de entrada e respostas para actions, sem alterar a lógica executada pelo endpoint.

Na primeira etapa, `IsAuthenticated` estabelece apenas que o usuário precisa estar autenticado. Isso não significa que qualquer usuário deva ter permissão para registrar pagamentos ou consultar todos os clientes. Para restringir o registro de locações a usuários administrativos do Django:

```python
from rest_framework.permissions import (
    IsAdminUser,
    IsAuthenticated,
)

class RentalViewSet(ReadOnlyListViewSet):
    queryset = models.Rental.objects.all()
    serializer_class = serializers.RentalSerializer

    def get_permissions(self):
        if self.action == "register":
            return [IsAdminUser()]

        return [IsAuthenticated()]

    # Manter aqui o método register,
    # incluindo os decoradores apresentados.
```

**Importante**: `IsAdminUser` verifica `user.is_staff` do Django; isso não representa automaticamente um registro da tabela staff do DVDRENTAL.

Também será necessário definir uma regra de negócio para o `staff_id` recebido pelo registro: autenticar alguém não prova que ele pode operar em nome de qualquer funcionário.

## 11. Testar pelo Swagger

Inicie o servidor:

```bash
python manage.py runserver
```

Acesse:

```text
http://127.0.0.1:8000/api/docs/
```

### Teste A — Sem autenticação

Certifique-se de que não há autorização cadastrada no Swagger.

Abra GET /api/addresses/.

Clique em Try it out.

Clique em Execute.

Resultado esperado nesta configuração: HTTP 401 Unauthorized.

Esse teste deve ser feito antes do login para demonstrar que o endpoint realmente exige autenticação.

### Teste B — Obter os tokens

Abra em AUTH: POST /api/auth/token/
Clique em Try it out e informe as credenciais criadas:

```json
{
  "username": "alunopabd",
  "password": "aluno2026"
}
```

Execute a requisição. Resposta esperada: HTTP 200, com dois campos:

```json
{
  "refresh": "<refresh token retornado>",
  "access": "<access token retornado>"
}
```

Os textos entre <...> acima representam os valores reais da resposta; não são tokens válidos.

### Teste C — Autorizar no Swagger

Copie somente o valor de `access` (sem as aspas).

Clique em Authorize, na parte superior da página.

Localize o esquema JWT, geralmente identificado como jwtAuth.

Cole o token.

Clique em Authorize.

Feche a janela.

### Teste D — Consultar o próprio perfil

Execute em AUTH: GET /api/auth/me/
Resultado esperado: HTTP 200, contendo o usuário autenticado:

```json
{
  "id": 2,
  "username": "alunopabd",
  "first_name": "Ana",
  "last_name": "Silva",
  "email": "ana@tads.ifrn"
}
```

Esse JSON é ilustrativo: o ID e os demais valores dependerão do usuário criado.

Evidência importante: o endpoint não recebe username nem ID. A identificação vem do token enviado na requisição.

### Teste E — Consultar o DVDRENTAL

Execute novamente: GET /api/addresses/
Resultado esperado: HTTP 200, com os dados retornados pelo endpoint.

Na área da requisição gerada pelo Swagger, confira se existe:

```text
Authorization: Bearer ...
```

### Teste F — Renovar o access token

Abra em AUTH: POST /api/auth/token/refresh/

Clique em Try It Out.

Envie o refresh token recebido no login:

```json
{
  "refresh": "<refresh token real>"
}
```

Resultado esperado: HTTP 200, com um novo access.

Depois:

Copie o novo access token.

Abra Authorize.

Remova a autorização anterior.

Cadastre o novo token.

Teste /api/auth/me/ novamente.

O Swagger não deve ser tratado como um cliente que renova e substitui automaticamente o token nesse fluxo manual.

### Teste G — Credenciais inválidas

No endpoint de login (/api/auth/token), informe uma senha incorreta.

Resultado esperado: HTTP 401, sem emissão dos tokens.

### Teste H — Token inválido

Em Authorize, substitua o token por um texto inválido e tente consultar /api/auth/me/.

Resultado esperado: HTTP 401.

Depois, remova a autorização inválida para continuar os testes.

### Teste I — Autenticado, mas sem permissão

Se a extensão com `IsAdminUser` foi implementada:

Autentique o usuário comum `alunopabd`.

Tente executar POST /api/rentals/register/.

Observe a resposta 403 Forbidden.

Autentique o administrador.

```json
{
  "username": "admin",
  "password": "tadspabd"
}
```

Repita com dados de negócio válidos.

```json
{
  "customer_id": 1,
  "inventory_id": 1,
  "staff_id": 1,
  "amount": "4.99"
}
```

No primeiro caso, a permissão deve impedir que a operação chegue ao serviço. No segundo, o sucesso ainda depende das validações, da disponibilidade do exemplar e da procedure existente.

Para listar todas as contas criadas, execute `python manage.py shell` e depois:

```python
from django.contrib.auth import get_user_model

User = get_user_model()
User.objects.filter().values(
    "username", "date_joined", "is_superuser"
)
```