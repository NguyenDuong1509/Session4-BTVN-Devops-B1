#!/usr/bin/env bash

BANNER='
  .   ____          _            __ _ _
 /\\ / ___'\''_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '\''_ | '\''_| | '\''_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '\''  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v3.2.0)
'

echo "$BANNER"
NOW=$(date +"%Y-%m-%d %H:%M:%S.000")
echo "$NOW  INFO 1 --- [main] c.s.storex.StorexApplication            : Starting StorexApplication v0.0.1-SNAPSHOT using Java 17.0.9"
echo "$NOW  INFO 1 --- [main] c.s.storex.StorexApplication            : The following 1 profile is active: \"default\""
echo "$NOW  INFO 1 --- [main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat initialized with port 8080 (http)"
echo "$NOW  INFO 1 --- [main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Starting..."

# Check if SPRING_DATASOURCE_URL contains localhost
if [[ "$SPRING_DATASOURCE_URL" == *"localhost"* ]]; then
    sleep 2
    ERR_TIME=$(date +"%Y-%m-%d %H:%M:%S.000")
    echo "$ERR_TIME ERROR 1 --- [main] com.zaxxer.hikari.pool.HikariPool        : HikariPool-1 - Exception during pool initialization."
    echo "org.postgresql.util.PSQLException: Connection to localhost:5432 refused. Check that the hostname and port are correct and that the postmaster is accepting TCP/IP connections."
    echo "	at org.postgresql.core.v3.ConnectionFactoryImpl.openConnectionImpl(ConnectionFactoryImpl.java:319)"
    echo "	at org.postgresql.core.ConnectionFactory.openConnection(ConnectionFactory.java:49)"
    echo "	at com.zaxxer.hikari.pool.PoolBase.newConnection(PoolBase.java:359)"
    echo "$ERR_TIME  WARN 1 --- [main] o.s.b.a.orm.jpa.JpaBaseConfiguration$JpaWebConfiguration : spring.jpa.open-in-view is enabled by default."
    echo "$ERR_TIME ERROR 1 --- [main] o.s.boot.SpringApplication               : Application run failed"
    exit 1
fi

# Extract host and port
HOST="postgres"
PORT="5432"

echo "$NOW  INFO 1 --- [main] c.s.storex.StorexApplication            : Connecting to database at $HOST:$PORT..."
while ! nc -z "$HOST" "$PORT" 2>/dev/null; do
    echo "$(date +"%Y-%m-%d %H:%M:%S.000")  INFO 1 --- [main] c.s.storex.StorexApplication            : Waiting for database ($HOST:$PORT) to become available..."
    sleep 1
done

CONN_TIME=$(date +"%Y-%m-%d %H:%M:%S.000")
echo "$CONN_TIME  INFO 1 --- [main] com.zaxxer.hikari.pool.HikariPool        : HikariPool-1 - Added connection org.postgresql.jdbc.PgConnection@3a82f6e9"
echo "$CONN_TIME  INFO 1 --- [main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Start completed."
echo "$CONN_TIME  INFO 1 --- [main] o.hibernate.jpa.internal.util.LogHelper  : HHH000204: Processing PersistenceUnitInfo [name: default]"
echo "$CONN_TIME  INFO 1 --- [main] org.hibernate.Version                    : HHH000412: Hibernate ORM core version 6.4.1.Final"
echo "$CONN_TIME  INFO 1 --- [main] o.h.e.t.j.p.i.JtaPlatformInitiator       : HHH000490: Using JtaPlatform implementation: [org.hibernate.engine.transaction.jta.platform.internal.NoJtaPlatform]"
echo "$CONN_TIME  INFO 1 --- [main] j.LocalContainerEntityManagerFactoryBean : Initialized JPA EntityManagerFactory for persistence unit 'default'"
echo "$CONN_TIME  INFO 1 --- [main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port 8080 (http) with context path ''"
echo "$CONN_TIME  INFO 1 --- [main] c.s.storex.StorexApplication            : Started StorexApplication in 3.421 seconds (process running for 4.125)"

# Keep container running and listening
while true; do
    nc -l -p 8080 -e echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 17\r\n\r\nStoreX API Online" 2>/dev/null || sleep 2
done

