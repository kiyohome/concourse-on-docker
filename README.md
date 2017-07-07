# concourse-on-docker

## Tools

- Concourse
  - port: 8888
  - team: main
  - username: concourse
  - password: password
- GitLab
  - port: 10080
  - username: root
  - password: password
- Sonarqube
  - port: 9000
  - username: admin
  - password: admin
  - if in proxy
    - https://docs.sonarqube.org/display/SONAR/Update+Center#UpdateCenter-UsingtheUpdateCenterbehindaProxy
  - install plugins
    - Administration > System > Update Center
    - plugins
      - SonarJava
      - Git
      - GitLab
- Nexus with ssl configuration
  - port: 18081
  - username: admin
  - password: admin123
- Rocket.Chat
  - port: 13000
  - register a new account

## Pipeline

- Notify task result on Concourse to Rocket.Chat
  - https://github.com/cloudfoundry-community/slack-notification-resource
- Notify test result on Concourse to Merge Request on Rocket.Chat
  - https://github.com/swisscom/gitlab-merge-request-resource
- Notify code analysis result on Concourse to Merge Request on Rocket.Chat
  - https://gitlab.talanlabs.com/gabriel-allaigre/sonar-gitlab-plugin

## How to use

### Prepare project on GitLab

- Create group and project on GitLab
  - group: sample
  - project: nablarch-example-web
- Push nablarch-example-web to project
```
$ git clone https://github.com/nablarch/nablarch-example-web.git
$ cd nablarch-example-web
$ git remote rm origin
$ git remote add origin http://root@localhost:10080/lapras/nablarch-example-web.git
$ git push -u origin master
```
- Create develop branch
```
$ git checkout -b develop
$ git push origin develop
```
- Add pipeline configuration to nablarch-example-web
  - Copy ci directory to nablarch-example-web
  - Push to repository

### Notify from Concourse to Rocket.Chat

- Create channel on Rocket.Chat
  - Name: concourse
- Create Incomming WebHook on Rocket.Chat
  - Administration > Integrations > NEW INTEGRATION > Incomming WebHook
    - Enabled: true
    - Name: concourse
    - Post to Channel: #concourse
- Copy the WebHook URL to ci/params.yml
```
chat-webhook-url: http://rocketchat:3000/hooks/token
```

### Change waitt version to create executable jar

- Bump waitt version to 1.2.0-SNAPSHOT
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

### Set mvn/docker repository on Nexus

- Set http proxy on Nexus, if necessary
  - Server administration and configuration > System > HTTP
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
- Add repository definition to nablarch-exmaple-web/pom.xml
  - Copy ci/pom.xml to nablarch-exmaple-web/pom.xml

### Set pipeline to Concourse

- Download fly.exe from top page on Concourse and put it in ci directory
- Set pipeline
```
$ fly -t main login -c http://concourse:8888/ -k
$ fly -t main sp -p nablarch-example-web -c pipeline.yml -l params.yml
```

