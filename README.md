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
$

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
