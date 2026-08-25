## Configurando PostgreSQL no Github Codespaces:

# 1. Instalando Postgres

```bash
sudo apt update
sudo apt install -y postgresql postgresql-client postgresql-contrib
sudo service postgresql start
```

# 2. Adicionar permissão
```bash
echo "codespace ALL=(postgres) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/codespace-postgres
sudo chmod 440 /etc/sudoers.d/codespace-postgres
```

# 3. Testar
```bash
sudo -u postgres psql -c "SELECT version();"
```

# 4. Criar um novo usuário e novo banco de dados
```bash
sudo -u postgres psql <<'SQL'
CREATE ROLE admin LOGIN PASSWORD 'root' SUPERUSER;
CREATE DATABASE pabd OWNER admin;
SQL
```

`<<'SQL' ... SQL` -> Heredoc: passa várias linhas SQL como entrada para o psql

# 5. Conectar com o novo usuário
```bash
psql -h 127.0.0.1 -U admin -d pabd
```

-h host
-p porta
-U usuário
-d database
-W força o prompt da senha (em vez de confiar em PGPASSWORD ou .pgpass)
-c comando SQL

Diferença importante: aqui usamos `127.0.0.1`, não `localhost`. No PostgreSQL, `localhost` pode tentar conexão via socket Unix (e, em alguns casos, usar autenticação peer), enquanto 127.0.0.1 força a conexão via TCP/IP, onde a autenticação por senha normalmente é exigida. Isso é crucial quando a role foi criada com senha.

# 6. Exibir todas as tabelas
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE';
```

# 7. Comando úteis do psql

Listar todas as tabelas: \dt
Mostrar a descrição de uma tabela: \d TABELA
Executar um arquivo: \i PATH
