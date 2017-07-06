# concourse-on-docker

## How to use

```
$ git clone https://github.com/kiyohome/concourse-on-docker.git
$ cd concourse-on-docker
```

### Concourse

- Install
```
$ cd concourse
$ ./generate-key.sh
$ docker-compose up -d
```

- Access "http://127.0.0.1:8888/" in the browser
- Login
  - team: main
  - username: concourse
  - password: password

### GitLab

- Install

```
$ cd gitlab
$ docker-compose up -d
```

- Access "http://127.0.0.1:10080/" in the browser
- Sign in
  - Username: root
  - Password: password

### Sonarqube

- Install

```
$ cd sonarqube
$ docker-compose up -d
```

- Access "http://127.0.0.1:9000/" in the browser
- Sign in
  - Username: admin
  - Password: admin
- Set proxy, if in proxy
  - https://docs.sonarqube.org/display/SONAR/Update+Center#UpdateCenter-UsingtheUpdateCenterbehindaProxy
- Install plugins
  - Administration > System > Update Center
    - Available: ON
    - Search: <input keywords>
  - plugins
    - SonarJava
    - Git
  - Restart

### Nexus

- Install

```
$ cd nexus
$ docker-compose up -d
```

- Access "http://127.0.0.1:18081/" in the browser
- Sign in
  - Username: admin
  - Password: admin123

### Rocket.Chat

- Install

```
$ cd rocketchat
$ docker-compose up -d
```

- Access "http://127.0.0.1:13000/" in the browser
- Register a new account

## Usecase for nablarch-example-web

### Prepare repository

- Create group and project on GitLab
  - group: lapras
  - project: nablarch-example-web
- Push to nablarch-example-web

```
$ git clone https://github.com/nablarch/nablarch-example-web.git
$ cd nablarch-example-web
$ git remote rm origin
$ git remote add origin http://root@localhost:10080/lapras/nablarch-example-web.git
$ git push -u origin master
```

- Create "develop" branch

```
$ git checkout -b develop
$ git push origin develop
```

### Code analysis with Sonar

- Add property for sonar-maven-plugin to pom.xml

```
<properties>
  <sonar.host.url>http://sonarqube:9000</sonar.host.url>
</properties>
```

- Run sonar

```
mvn clean verify sonar:sonar
```

### Nofify from Concourse to Rocket.Chat

using https://github.com/cloudfoundry-community/slack-notification-resource

- Create channel on Rocket.Chat
  - Name: concourse
- Create Incomming WebHook on Rocket.Chat
  - Administration > Integrations > NEW INTEGRATION > Incomming WebHook
    - Enabled: true
    - Name: concourse
    - Post to Channel: #concourse
- Copy the WebHook URL to char resource in pipeline.yml

```
resource_types:
- name: slack-notification
  type: docker-image
  source:
    repository: cfcommunity/slack-notification-resource
    tag: latest

resources:
- name: chat
  type: slack-notification
  source:
    url: <Incomming WebHook>

jobs:
- name: unit-test-develop
  plan:
  - aggregate:
    - get: source
      resource: develop
      trigger: true
    - get: mvn
    - get: m2
  - task: mvn-test
    image: mvn
    file: source/ci/tasks/mvn-test.yml
  on_success:
    <<: *notify_success
  on_failure:
    <<: *notify_failure

notify_success: &notify_success
  put: chat
  params:
    no_proxy: rocketchat
    channel: '#concourse'
    text: "$BUILD_PIPELINE_NAME/$BUILD_JOB_NAME: $ATC_EXTERNAL_URL/builds/$BUILD_ID"
    attachments:
      - title: Job Success!
        color: "good"

notify_failure: &notify_failure
  put: chat
  params:
    no_proxy: rocketchat
    channel: '#concourse'
    text: "$BUILD_PIPELINE_NAME/$BUILD_JOB_NAME: $ATC_EXTERNAL_URL/builds/$BUILD_ID"
    attachments:
      - title: Job Failure!
        color: "danger"
```

### Executable jar using waitt

- Bump to 1.2.0-SNAPSHOT
```
      <plugin>
        <groupId>net.unit8.waitt</groupId>
        <artifactId>waitt-maven-plugin</artifactId>
        <version>1.2.0-SNAPSHOT</version>
        <configuration>
          <servers>
            <server>
              <groupId>net.unit8.waitt.server</groupId>
              <artifactId>waitt-tomcat8</artifactId>
              <version>1.2.0-SNAPSHOT</version>
            </server>
          </servers>
        </configuration>
      </plugin>
```

- Run executable jar

```
mvn waitt:jar
java -jar target/nablarch-example-web-5u10-standalone.jar -d src/main/webapp -p 3333
```

### Add pipeline to nablarch-example-web

- Copy ci directory to nablarch-example-web
- Download fly.exe from the top page of Concourse
- Set pipeline on ci directory

```
$ fly -t main login -c http://localhost:8888/ -k
$ fly -t main sp -p nablarch-example-web -c pipeline.yml -l credentials.yml
```

### Configure mvn/docker repository on Nexus

- Server administration and configuration > Repositories > Create repository
  - seasar
    - Recipe: maven2(proxy)
    - Name: seasar
    - Proxy > Remote storage: http://maven.seasar.org/maven2
  - clojars
    - Recipe: maven2(proxy)
    - Name: clojars
    - Proxy > Remote storage: https://clojars.org/repo
  - sonatype
    - Recipe: maven2(proxy)
    - Name: sonatype
    - Proxy > Remote storage: https://oss.sonatype.org/content/repositories/snapshots/
  - docker-hub
    - Recipe: docker(proxy)
    - Name: docker-hub
    - Proxy > Remote storage: https://registry-1.docker.io
  - docker-public
    - Recipe: docker(group)
    - Name: docker-public
    - Repository Connectors > HTTPS: 18444
    - Group > Member repositories > Members: docker-hub
- Set http proxy on Nexus, if necessary
  - Server administration and configuration > System > HTTP
- Update repository and  in pom.xml
```
  <repositories>
    <repository>
      <id>private-public</id>
      <url>https://<host>:18443/repository/maven-public/</url>
      <releases>
        <enabled>true</enabled>
      </releases>
      <snapshots>
        <enabled>true</enabled>
      </snapshots>
    </repository>
  </repositories>

  <pluginRepositories>
    <pluginRepository>
      <id>private-public-plugin</id>
      <url>https://<host>:18443/repository/maven-public/</url>
      <releases>
        <enabled>true</enabled>
      </releases>
      <snapshots>
        <enabled>true</enabled>
      </snapshots>
    </pluginRepository>
  </pluginRepositories>

  <distributionManagement>
    <repository>
      <id>private-release</id>
      <url>https://<host>:18443/repository/maven-releases/</url>
    </repository>
    <snapshotRepository>
      <id>private-snapshot</id>
      <url>https://<host>:18443/repository/maven-snapshots/</url>
    </snapshotRepository>
  </distributionManagement>
```
- Update docker-image resource in pipeline.yml
```
- name: m2
  type: docker-image
  source:
    username: {{nexus-username}}
    password: {{nexus-password}}
    repository: <host>:<port>/kiyohome/nablarch-in-mvn
    tag: 5u10-1
    insecure_registries:
      - <host>:<port>
```

### Update the merge request status

using https://github.com/swisscom/gitlab-merge-request-resource

```
resource_types:
- name: merge-request
  type: docker-image
  source:
    repository: mastertinner/gitlab-merge-request-resource

resources:
- name: mr
  type: merge-request
  source:
    private_token: {{git-accesstoken}}
    username: {{git-username}}
    password: {{git-password}}
    uri: http://ito.kiyohito@172.24.34.14:10080/lapras/nablarch-example-web.git
    no_ssl: true

jobs:
- name: unit-test-mr
  plan:
  - aggregate:
    - get: source
      resource: mr
      trigger: true
    - get: mvn
    - get: m2
  - put: mr
    params:
      repository: source
      status: running
  - task: mvn-test
    image: mvn
    file: source/ci/tasks/mvn-test.yml
    on_success:
      put: mr
      params:
        repository: source
        status: success
    on_failure:
      put: mr
      params:
        repository: source
        status: failed
  on_success:
    <<: *notify_success
  on_failure:
    <<: *notify_failure
```