# create CH super user
resource "random_password" "clickhouse_password_test" {
  length  = 40
  special = false
}

# for gitlab ci/cd pipeline
resource "random_password" "ci_password" {
  length  = 40
  special = false
}

# for metabase tool
resource "random_password" "metabase_pwd" {
  length  = 40
  special = false
}

resource "random_password" "prd_password" {
  length  = 40
  special = false
}

resource "helm_release" "clickhouse-test" {
  namespace = local.namespace
  name      = "clickhouse"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "clickhouse"
  version    = "4.1.13" # bitnami clickhouse helm chart version - https://artifacthub.io/packages/helm/bitnami/clickhouse

  timeout = 90
  wait    = false

  values = [
    <<EOF
global:
  storageClass: "gp3" # for persistence volumes

image:
  registry: docker.io
  repository: bitnami/clickhouse
  tag: 23.11.2-debian-11-r1 # clickhouse version
  pullPolicy: IfNotPresent

shards: 1
replicaCount: 3

resources:
  limits:
    memory: 6Gi
  requests:
    cpu: 500m
    memory: 4Gi

# admin user
auth:
  username: brenda
  password: ${random_password.clickhouse_password_test.result}

keeper:
  enabled: false

extraOverrides: |
  <clickhouse>
    <users>
      <ci_user>
        <password>${random_password.ci_password.result}</password>
        <grants>
          <query>GRANT dev_role</query>
        </grants>
      </ci_user>
      <metabase>
        <password>${random_password.metabase_pwd.result}</password>
        <grants>
          <query>GRANT metabase_role</query>
        </grants>
      </metabase>
      <dbt_prd>
        <password>${random_password.prd_password.result}</password>
        <grants>
          <query>GRANT prd_role</query>
        </grants>
      </dbt_prd>
    </users>
    <roles>
      <dev_role>
    	  <grants>
    		  <query>GRANT SHOW DATABASES ON warehouse_dev.*</query>
          <query>GRANT SELECT ON *.*</query>
    	    <query>GRANT CREATE ON warehouse_dev.*</query>
          <query>GRANT TRUNCATE ON warehouse_dev.*</query>
          <query>GRANT INSERT ON warehouse_dev.*</query>
          <query>GRANT DROP TABLE, DROP VIEW ON warehouse_dev.*</query>
          <query>GRANT SYSTEM SYNC REPLICA ON warehouse_dev.*</query>
          <query>GRANT ALTER DELETE ON warehouse_dev.*</query>
          <query>GRANT ALTER UPDATE ON warehouse_dev.*</query>
          <query>GRANT CREATE TEMPORARY TABLE, POSTGRES ON *.*</query>
          <query>GRANT REMOTE ON *.*</query>
        </grants>
      </dev_role>
      <metabase_role>
    	  <grants>
    	    <query>GRANT SHOW DATABASES ON *.*</query>
          <query>GRANT SELECT ON *.*</query>
    	  </grants>
      </metabase_role>
      <prd_role>
    	  <grants>
    	    <query>GRANT SELECT ON *.*</query>
          <query>GRANT REMOTE ON *.*</query>
          <!-- prod_db -->
          <query>GRANT SHOW DATABASES ON prod_db.*</query>
          <query>GRANT CREATE ON prod_db.*</query>
          <query>GRANT CREATE TABLE ON prod_db.*</query>
          <query>GRANT TRUNCATE ON prod_db.*</query>
          <query>GRANT INSERT ON prod_db.*</query>
          <query>GRANT DROP TABLE, DROP VIEW ON prod_db.*</query>
          <query>GRANT SYSTEM SYNC REPLICA ON prod_db.*</query>
          <query>GRANT ALTER DELETE ON prod_db.*</query>
          <query>GRANT ALTER UPDATE ON prod_db.*</query>
          <!-- g_analytics db -->
          <query>GRANT CREATE ON g_analytics.*</query>
          <query>GRANT CREATE TABLE ON g_analytics.*</query>
          <query>GRANT TRUNCATE ON g_analytics.*</query>
          <query>GRANT INSERT ON g_analytics.*</query>
          <query>GRANT DROP TABLE, DROP VIEW ON g_analytics.*</query>
          <query>GRANT SYSTEM SYNC REPLICA ON g_analytics.*</query>
          <query>GRANT ALTER DELETE ON g_analytics.*</query>
          <query>GRANT ALTER UPDATE ON g_analytics.*</query>
          <!-- global -->
          <query>GRANT CREATE TEMPORARY TABLE, POSTGRES ON *.*</query>
        </grants>
      </prd_role>
    </roles>
  </clickhouse>

persistence:
  enabled: true
  accessModes:
    - ReadWriteOnce
  size: 100Gi
  
metrics:
  enabled: true
  serviceMonitor:
    enabled: true

zookeeper:
  enabled: false

externalZookeeper:
  servers:
    - zookeeper.stg # name (provider's context)
  port: 2181
    EOF
  ]
  depends_on = [helm_release.zookeeper-test] # resource name (terrafomr context)
}

resource "helm_release" "zookeeper-test" {
  namespace = local.namespace
  name      = "zookeeper"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "zookeeper"
  version    = "12.3.4" # bitnami zookeeper helm chart version - https://artifacthub.io/packages/helm/bitnami/zookeeper

  timeout = 90
  wait    = false

  values = [
    <<EOF
global:
  storageClass: "gp3" # for persistance volumes

replicaCount: 1
image:
  registry: docker.io
  repository: bitnami/zookeeper
  tag: 3.8.3-debian-11-r3 # zookeeper version https://hub.docker.com/r/bitnami/zookeeper/tags?page=1

autopurge:
  snapRetainCount: 3
  purgeInterval: 72

resources:
  limits:
    memory: 512Mi
  requests:
    memory: 512Mi
    cpu: 50m

persistence:
  enabled: true
  storageClass: gp3
  accessModes:
    - ReadWriteOnce
  size: 1Gi
    EOF
  ]
}