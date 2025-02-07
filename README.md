# sqlx-migrator

`sqlx-migrator` is a docker image that applies `sqlx` migrations from a git repository to a database. This is useful for
Kubernetes init containers, as they can apply the table-altering queries with higher privileges than the application
that uses the database.

Additionally, because this image first pulls the complete set of migrations from a git repository, it even supports
rollbacks, like those from Helm. Each version of the chart should specify the identifier of the latest migration the
application supports. If the user updates the chart, or rolls back to a previous version, the init container will apply
as many `up` or `down` migrations as necessary to turn the current version of the database into the version the
application expects.

## Usage

Add an init container to your pod's manifest:

```yaml
initContainers:
  - name: "sqlx-migrator"
    image: "ghcr.io/tortoaster/sqlx-migrator:v1.0.0"
    env:
      {{- with .Values.sqlxMigrator }}
      - name: "REPO"
        value: {{ .repo | required "sqlxMigrator.repo required" }}
      - name: "REV"
        value: {{ .rev }}
      - name: "MIGRATIONS_DIR"
        value: {{ .migrationsDir }}
      - name: "TARGET_VERSION"
        value: {{ .targetVersion | required "sqlxMigrator.targetVersion required" }}
      {{- end }}
      {{- with .Values.db }}
      {{- with .admin }}
      - name: "DB_USER"
        value: {{ .name }}
      {{- with .passwordSecret }}
      - name: "DB_PASSWORD"
        valueFrom:
          secretKeyRef:
            name: {{ .name | required "db.admin.passwordSecret.name required" }}
            key: {{ .key | required "db.admin.passwordSecret.key required" }}
      {{- end }}
      {{- end }}
      - name: "DB_HOST"
        value: {{ .host | required "db.host required" }}
      - name: "DB_PORT"
        value: {{ .port | quote }}
      - name: "DB_DATABASE"
        value: {{ .database | required "db.database required" }}
      {{- end }}
```

And merge and/or adapt these values into your `values.yaml`:

```yaml
sqlxMigrator:
  # repository that hosts the migration files
  repo: ""
  # revision (branch/tag/hash) that contains the most complete list of migrations - this usually only needs to be changed if you want to test new migrations on a different branch
  rev: "HEAD"
  # directory within the repository that contains the migrations
  migrationsDir: "migrations"
  # version of the most recent migration that is compatible with this version of the application - note that this is always a number like 20250207222531, but be sure to put it between quotes to prevent YAML from converting it to scientific notation
  targetVersion: ""

db:
  admin:
    # name of the admin database user
    name: ""
    passwordSecret:
      # name of the secret resource that contains the admin user's database password
      name: ""
      # key within the secret that corresponds to the admin user's database password
      key: ""
  # host that serves the database
  host: ""
  # port the database listens to
  port: 5432
  # database name
  database: ""
```

## License

Licensed under either of

* Apache License, Version 2.0
  ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
* MIT license
  ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

## Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in the work by you, as
defined in the Apache-2.0 license, shall be dual licensed as above, without any additional terms or conditions.
