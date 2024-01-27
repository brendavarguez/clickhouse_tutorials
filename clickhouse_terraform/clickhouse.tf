# create CH super user
resource "random_password" "clickhouse_password_test" {
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
auth:
  username: brenda
  password: ${random_password.clickhouse_password_test.result}

keeper:
  enabled: false

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