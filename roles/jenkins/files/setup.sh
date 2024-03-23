#!/bin/bash
set -x
export domain=$1
export secret=$2
export namespace=$3
export mysql_db_password=$4

cat > values.yaml << EOF

controller:
  adminUser: "admin"
  adminPassword: "jenkins"
  jenkinsUrlProtocol: "https"
  jenkinsHome: "/var/jenkins_home"
  jenkinsUrl: https://jenkins.$domain
  ingress:
    enabled: true
    annotations:
      kubernetes.io/tls-acme: "false"
    ingressClassName: nginx
    hostName: jenkins.$domain
    path: '/'
    tls:
      - secretName: $secret
        hosts:
          - jenkins.$domain
  installLatestPlugins: true
  installPlugins:
    - git:5.2.0
    - database-mysql:1.4
    - github:1.34.0
    - gitlab-plugin:1.7.16
    - pipeline-stage-view:2.33
    - database:191.vd5981b_97a_5fa_
    - locale:314.v22ce953dfe9e
    - kubernetes:4029.v5712230ccb_f8
    - workflow-job:1326.ve643e00e9220
    - workflow-aggregator:596.v8c21c963d92d
    - credentials-binding:636.v55f1275c7b_27
    - configuration-as-code:1670.v564dc8b_982d0
    - docker-workflow:1.26  # 添加 Docker Pipeline 插件
    - workflow-cps:2.92     # 添加 Pipeline 插件
  JCasC:
    enabled: true
    defaultConfig: true
    configScripts:
      database: |
        unclassified:
          globalDatabaseConfiguration:
            database:
              mysql:
                hostname: mysql.database.svc.cluster.local
                port: '3306'
                username: "root"
                database: "jenkins"
                password: $mysql_db_password
                properties: "?useSSL=false"
                validationQuery: "SELECT 1"
agent:
  enabled: true
  replicas: 3
  numExecutors: 1
  jenkinsUrl: https://jenkins.$domain

persistence:
  enabled: true
  storageClass: "local-path"
  size: "10Gi"
networkPolicy:
  enabled: false
backup:
  enabled: false
additionalConfig: {}
EOF

helm repo add jenkins https://charts.jenkins.io
helm repo update
#helm upgrade --install jenkins jenkins/jenkins --version 4.1.1 -f values.yaml
helm upgrade --install jenkins jenkins/jenkins -n $namespace --create-namespace -f values.yaml 