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
- name: unit-test
  plan:
  - aggregate:
    - get: …
  - task: mvn-test
    image: …
    on_success:
      put: chat
      params:
        no_proxy: rocketchat
        channel: '#concourse'
        text: http://localhost:8888/teams/$BUILD_TEAM_NAME/pipelines/$BUILD_PIPELINE_NAME/jobs/$BUILD_JOB_NAME/builds/$BUILD_NAME
        attachments:
          - title: Job Success!
            color: "good"
    on_failure:
      put: chat
      params:
        no_proxy: rocketchat
        channel: '#concourse'
        text: http://localhost:8888/teams/$BUILD_TEAM_NAME/pipelines/$BUILD_PIPELINE_NAME/jobs/$BUILD_JOB_NAME/builds/$BUILD_NAME
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
