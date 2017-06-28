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
- Set pipeline
```
$ fly -t main login -c http://localhost:8888/ -k
$ fly -t main sp -p nablarch-example-web -c pipeline.yml -l credentials.yml

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
- Add sonar-maven-plugin
  - Add property to pom.xml
```
<properties>
  <sonar.host.url>http://sonarqube:9000</sonar.host.url>
</properties>
```
  - Run
```
mvn clean verify sonar:sonar
```

## Usecase

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
