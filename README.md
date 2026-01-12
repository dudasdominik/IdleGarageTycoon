# IdleGarageTycoon (Production) – Docker stack

Repo: https://github.com/dudasdominik/IdleGarageTycoon

Ez a repository egy “production / deployment” csomag, ami Dockerrel felhúzza a teljes rendszert:

- **Frontend**: Vite + React (Nginx szolgálja ki)
- **Backend**: ASP.NET Core (.NET)
- **Database**: PostgreSQL
- **EF Core migrations**: automatikusan lefut indításkor

---

## Követelmények

- **Docker** (Windows/Mac: Docker Desktop, Linux: Docker Engine)
- **Git**
- Szabad portok:
  - **80** → web (frontend)
  - **3254** → postgres (hostra kiexportálva)

> Ha a **80-as port foglalt**, a `docker-compose.yml`-ben a `web` service `ports` részét állítsa át pl. `8080:80`-ra.

---

## Letöltés (submodule-okkal együtt)

A repo backend/frontend részei submodule-ként vannak kezelve, ezért **recurse-submodules** kell.

### Ajánlott klónozás
```bash
git clone --recurse-submodules https://github.com/dudasdominik/IdleGarageTycoon
cd IdleGarageTycoon
```

Ha már lett clonozva, de hiányoznak a submodule-ok

```bash
git submodule update --init --recursive
```

### Konfiguráció (.env)

A futtatáshoz a repo gyökerében kell egy .env.

Másolja le az example-t:

.env.example → .env

Töltse ki / ellenőrizze az értékeket:

PG_USER, PG_PASSWORD, PG_DATABASE, PG_PORT

Jwt__Issuer, Jwt__Audience

Jwt__Key (legyen hosszú, random secret)

A .env nincs commitolva (ne pusholja fel).
A scriptek ebből olvasnak induláskor.

### Indítás (Windows)

A repo gyökerében futtassa:

```bash
run-production.bat
```

A script:

buildeli a Docker image-eket
elindítja a PostgreSQL-t
lefuttatja az EF Core migrációkat
elindítja a backend + frontend konténereket

### Elérés

Frontend: http://localhost

API: a frontend nginx proxy-n keresztül /api/ alatt érhető el
példa: http://localhost/api/Auth/...

### Leállitás:
```bash
docker compose down
```

### Teljes törlés
```bash
docker compose down -v
```
