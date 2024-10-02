# Load Balancing Deployment: Kubernetes 🚜

---
<br>

## 목적 ✒

k8s에서 3개의 파드를 생성하는 주된 목적은 **로드 밸런싱과 높은 가용성을 확보하는 것**입니다. 이 프로젝트에서 로드 밸런싱을 통해 클라이언트 요청을 여러 파드에 효과적으로 분산시키고, 이로 인해 단일 파드에 과부하가 걸리는 상황을 방지하여 **애플리케이션의 성능을 최적화하는 것**을 제공합니다.

---

<br>

## 실습환경 🏞

```ruby
virtualbox: version 7.0
ubuntu: version 22.04.4 LTS
docker: version 27.3.1
minikube: version v1.34.0
```

---

<br>

## 이미지 생성 🖼

#### 1️⃣) docker image를 생성하기 위해 dockerfile을 생성해줍니다.

```ruby
FROM openjdk:17-jdk-slim

WORKDIR /app

COPY SpringApp-0.0.1-SNAPSHOT.jar /app/SpringApp.jar

ENTRYPOINT ["java", "-jar", "/app/SpringApp.jar"]
```

#### 2️⃣) dockerfile을 build 해준 후 로그인을 한 상태에서 docker hub에 push 해줍니다.

```ruby
#dockerfile을 빌드
docker build -t isshomin/test-spring:1.0 .

#docker hub 로그인
docker login

# docker hub에 image 푸쉬
docker push isshomin/test-spring:1.0
```
![image](https://github.com/user-attachments/assets/02d82d16-65ff-41ad-8c67-eec8ffd1643c)
<br>

![image](https://github.com/user-attachments/assets/b8397de2-d5d4-4735-905e-fa23209d9c9c)
<br>

[docker_hub](https://hub.docker.com/repository/docker/isshomin/test-spring/general)
---

<br>

## yml파일 작성 📃

#### 1️⃣) minikube에 deployment를 만들기 위한 yml파일을 작성합니다. 

**spring_deployment.yml**
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-spring-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: test-spring-container
        image: isshomin/test-spring:1.0 #docker hub에 푸쉬한 image 사용
        resources:
          limits:
            memory: "128Mi"
            cpu: "250m"
        ports:
        - containerPort: 8999 #app의 server.port와 동일하게 설정
```

#### 2️⃣) minikube에 service를 만들기 위한 yml파일을 작성합니다. 

**spring_svc.yml**
```yml
apiVersion: v1
kind: Service
metadata:
  name: test-spring-svc
spec:
  type: LoadBalancer #로드밸런싱을 위한 타입설정
  selector:
    app: myapp
  ports:
  - port: 80 #외부와 통신할 port
    targetPort: 8999 #depolyment의 containerPort와 동일하게 설정
```

---

<br>

## deployment & service 생성 💾

#### 1️⃣) kubectl 명령어를 사용하여 .yml 파일을 통해 각 deployment와 service를 생성해줍니다. 

```ruby
#deployment 생성
kubectl apply -f spring_deployment.yml

#
kubectl apply -f spring_svc.yml
```

#### 2️⃣) kubectl 명령어를 사용하여 생성이 제대로 되었는지 확인해줍니다.

```ruby
kubectl get all
```

**출력 결과 🖨**

![image](https://github.com/user-attachments/assets/4d228f66-e339-41f2-8927-ada36be4467a)
<br>

#### 3️⃣) minikube에서 외부 IP 제공받기 위한 터널링을 해줍니다.

```ruby
minikube tunnel
```

**출력 결과 🖨**

![image](https://github.com/user-attachments/assets/608cd053-f91e-478c-949f-a0a75e505ca8)


---

<br>

## 실행 테스트 및 로그확인 🎬

#### 1️⃣) 외부에서 통신할 수있게 포트포워딩을 해줍니다.

![image](https://github.com/user-attachments/assets/798d7025-68dc-4010-aeb7-32954e6c4dc1)


#### 2️⃣) url을 입력하여 접속을 확인합니다.

```ruby
curl 10.107.217.179/test
```

**출력 결과 🖨**

![image](https://github.com/user-attachments/assets/a701bf60-6ef1-4208-b3e1-a9872524555c)


#### 3️⃣) dashboard에 접속하여 로드밸런싱이 제대로 되었는지 확인해봅니다.

![image](https://github.com/user-attachments/assets/d12e7ac2-b781-491d-b23d-61c49a21c7c6)


**1번 파드 log**

![image](https://github.com/user-attachments/assets/16583b52-eb85-4b87-ae75-1bccdf2b4ad2)
<br>

**2번 파드 log**

![image](https://github.com/user-attachments/assets/3267399e-8367-43e9-973e-ac66e75c0ec8)
<br>

**3번 파드 log**

![image](https://github.com/user-attachments/assets/3124d31d-3d81-4ba3-a047-d5d62c999c2a)

---

<br>


## 요약 📩

#### 다수의 파드를 생성하여 로드밸런싱을 통해 클라이언트 요청을 여러 파드에 균등하게 분산하여 단일 파드의 과부하를 방지하고, 전체 애플리케이션의 성능을 향상시켰습니다.
#### 여러 파드를 동시에 운영함으로써 하나의 파드에서 장애가 발생하더라도 서비스 중단 없이 지속적으로 사용자에게 서비스를 제공할 수 있도록 했습니다.

<br>

---

## 트러블슈팅 🎯🔫

### 1️⃣) 3개 중 1개의 파드가 pending인 상황 ⛈

![image](https://github.com/user-attachments/assets/abc4a6dd-ffe1-4143-9d7b-4fd78f06fb73)
<br>
![image](https://github.com/user-attachments/assets/bee4952d-94dd-4798-be01-01c18fc9111e)
<br>

### 원인추론 ⛅

#### 다음의 명령어를 통해서 파드의 이벤트 로그를 확인합니다.

```ruby
kubectl describe pod test-spring-deployment-<pod_name>
```

**출력 결과 🖨**

0/1 nodes are available: 1 Insufficient cpu.

#### 출력 결과를 통해 파드가 요청하는 CPU 리소스가 노드의 가용 자원보다 많아서 발생하고 있다는 것을 확인했습니다.

```ruby
#기존의  deployment yml파일에서의 mcpu 설정
limits:
  memory: "128Mi"
  cpu: "500m"
```

<br>

### 해결 🌞

#### 기존의 deployment yml파일에서 컨테이너가 사용할 수 있는 CPU의 최대 한도를 250m CPU로 설정하여 해결했습니다.

![image](https://github.com/user-attachments/assets/044251a8-039e-4437-939e-3b372465364a)
<br>

![image](https://github.com/user-attachments/assets/c50c2b41-6e5d-4bb3-8727-8a80884c79b7)
<br>

<br>

### 2️⃣) 파드가 Running상태지만 url 접속이 안되는 상황 ⛈

![image](https://github.com/user-attachments/assets/1a292ac5-ba09-44d2-bbb7-99ae1b6c3762)
<br>

![image](https://github.com/user-attachments/assets/85cf88a6-579c-4db0-915a-8b7bd14465ff)
<br>


### 원인추론 ⛅

#### 각각의 포트번호를 확인합니다.
|      |port        |
|-----------|------------|
|.jar |8999         |
|container   |8080         |
|extra   |80         |

#### 컨테이너의 포트와 jar파일의 server.port가 일치하지 않다는 것을 발견했습니다. 

<br>

### 해결 🌞

#### .jar파일의 application.properties에서 server.port 설정한 포트와 Kubernetes의 Deployment 또는 Service에서 설정한 포트가 일치해야하므로 포트가 일치하도록 수정했습니다.
|      |port        |
|-----------|------------|
|.jar |8999         |
|container   |8999         |
|extra   |80         |

---
