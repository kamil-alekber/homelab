# Install apps:

### Audobookshelf:
- docker compose
```yaml
services:
  audiobookshelf:
    image: ghcr.io/advplyr/audiobookshelf:latest
    ports:
      - 13378:80
    volumes:
      - </path/to/audiobooks>:/audiobooks
      - </path/to/podcasts>:/podcasts
      - </path/to/config>:/config
      - </path/to/metadata>:/metadata
    environment:
      - TZ=America/Toronto
```

### sotry tellar
- docker compose
```yml
services:
  web:
    image: registry.gitlab.com/storyteller-platform/storyteller:latest
    volumes:
      - ~/Documents/Storyteller:/data:rw
    environment:
      - STORYTELLER_SECRET_KEY=687213a0c9d5645936564519495c7adf
    ports:
      - "8001:8001"
```

### Download Books:
[ephemera](https://github.com/OrwellianEpilogue/ephemera?ref=selfh.st)
- docker compose
```yml
services:
  ephemera:
    image: ghcr.io/orwellianepilogue/ephemera:latest
    container_name: ephemera
    restart: unless-stopped

    ports:
      - "8286:8286"

    environment:
      # Required:
      AA_BASE_URL:
      # FlareSolverr is used for slow download fallback when API key is missing or quota exhausted
      # Default: http://127.0.0.1:8191 (or http://flaresolverr:8191 in Docker)
      FLARESOLVERR_URL: http://127.0.0.1:8191

      # Optional

      # Alternative Download Source (optional, but highly recommended)
      # If set, LG fast download will be attempted before falling back to slow servers
      # Leave empty to disable this feature
      # li, bz, etc.
      LG_BASE_URL: #https://gen.com

      AA_API_KEY:
      PUID: 1000
      PGID: 100

    volumes:
      - ./data:/app/data
      - ./downloads:/app/downloads
      - ./ingest:/app/ingest

    # Set DNS server to prevent EU blocking
    #dns:
    #  - 1.1.1.1
    #  - 1.0.0.1
```
[Book Downloader](https://github.com/calibrain/calibre-web-automated-book-downloader?ref=selfh.st)
- docker compose:
```yml
services:
  calibre-web-automated-book-downloader:
    image: ghcr.io/calibrain/calibre-web-automated-book-downloader:latest
    container_name: calibre-web-automated-book-downloader
    environment:
      TZ: America/New_York
      # UID: 1000
      # GID: 100
      # CWA_DB_PATH: /auth/app.db
    ports:
      - 8084:8084
    restart: unless-stopped
    volumes:
      - /tmp/data/calibre-web/ingest:/cwa-book-ingest # This is where the books will be downloaded and ingested by your book management application
      - /path/to/config:/config # Configuration files and database
```

### Cloud Browser:
[cloudreve](https://docs.cloudreve.org/en/overview/deploy/docker-compose)
```yml
services:
  cloudreve:
    image: cloudreve/cloudreve:latest
    container_name: cloudreve-backend
    depends_on:
      - postgresql
      - redis
    restart: unless-stopped
    ports:
      - 5212:5212
      - 6888:6888
      - 6888:6888/udp
    environment:
      - CR_CONF_Database.Type=postgres
      - CR_CONF_Database.Host=postgresql
      - CR_CONF_Database.User=cloudreve
      - CR_CONF_Database.Name=cloudreve
      - CR_CONF_Database.Port=5432
      - CR_CONF_Redis.Server=redis:6379
    volumes:
      - backend_data:/cloudreve/data

  postgresql:
    # Best practice: Pin to major version. 
    # NOTE: For major version jumps:
    # backup & consult https://www.postgresql.org/docs/current/pgupgrade.html 
    image: postgres:17    
    container_name: postgresql
    restart: unless-stopped
    environment:
      - POSTGRES_USER=cloudreve
      - POSTGRES_DB=cloudreve
      - POSTGRES_HOST_AUTH_METHOD=trust
    volumes:
      - database_postgres:/var/lib/postgresql/data

  redis:
    image: redis:latest
    container_name: redis
    restart: unless-stopped
    volumes:
      - redis_data:/data

volumes:
  backend_data:
  database_postgres:
  redis_data:
```
# if bored
### Kinto JSON api 
[kinto](https://docs.kinto-storage.org/en/latest/overview.html)
```yml
version: "3"
services:
  db:
    image: postgres:14
    environment:
      POSTGRES_NAME: postgres
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "postgres"]
      interval: 5s
      timeout: 5s
      retries: 5
  cache:
    image: memcached:1
  web:
    build:
      context: .
      dockerfile: Dockerfile
    image: kinto/kinto-server:latest
    depends_on:
      db:
        condition: service_healthy
      cache:
        condition: service_started
    ports:
    - "8888:8888"
    environment:
      KINTO_CACHE_BACKEND: kinto.core.cache.memcached
      KINTO_CACHE_HOSTS: cache:11211 cache:11212
      KINTO_STORAGE_BACKEND: kinto.core.storage.postgresql
      KINTO_STORAGE_URL: postgresql://postgres:postgres@db/postgres
      KINTO_PERMISSION_BACKEND: kinto.core.permission.postgresql
      KINTO_PERMISSION_URL: postgresql://postgres:postgres@db/postgres
```