# 쿠버네티스 클러스터 배포 스크립트

1. [쿠버네티스 클러스터 배포 스크립트](#쿠버네티스-클러스터-배포-스크립트)
   1. [시작하기 전에](#시작하기-전에)
      1. [필요한 환경](#필요한-환경)
      2. [설치 내용 정보](#설치-내용-정보)
   2. [단계별 설명](#단계별-설명)
      1. [모든 노드에서 실행할 스크립트](#모든-노드에서-실행할-스크립트)
         1. [1. `all-01-kernel.sh`](#1-all-01-kernelsh)
         2. [2. `all-02-cri.sh`](#2-all-02-crish)
         3. [3. `all-03-k8s-tools.sh`](#3-all-03-k8s-toolssh)
      2. [Control-Plane(컨트롤 플레인)에서만 실행](#control-plane컨트롤-플레인에서만-실행)
         1. [1. `cp-01-kubeadm-init.sh`](#1-cp-01-kubeadm-initsh)
         2. [2. `cp-02-kubeconfig.sh`](#2-cp-02-kubeconfigsh)
         3. [3. `cp-03-flannel.sh`](#3-cp-03-flannelsh)
   3. [스크립트를 적용한 후에 할 것](#스크립트를-적용한-후에-할-것)
   4. [클러스터를 재배포(재설치) 할 때 주의할 점](#클러스터를-재배포재설치-할-때-주의할-점)
      1. [몇몇 파일은 수동으로 파일을 지우거나 수정해야 함](#몇몇-파일은-수동으로-파일을-지우거나-수정해야-함)
      2. [몇가지 툴 (kubelet, CRI) 은 재설치하더라도 설정파일을 생성하지 못함](#몇가지-툴-kubelet-cri-은-재설치하더라도-설정파일을-생성하지-못함)

---

실행 순서는 아래와 같음

1. 모든 노드에서 실행할 스크립트 실행
2. Control-Plane(마스터)에서만 실행할 스크립트 실행
3. 워커(슬레이브) 노드에서 클러스터로 Join 명령 실행

## 시작하기 전에

### 필요한 환경

1. 모든 노드는 서로서로 IP로 접속할 수 있어야 함
2. CIDR 10.244.0.0/16 대역과 겹치는 IP대역이 없어야 함 (_Flannel_ CNI가 이 대역을 사용해야 함)
3. 모든 노드의 swap 메모리가 꺼져있어야 함

### 설치 내용 정보

- CRI(Container Runtime Interface, 컨테이너 런타임 인터페이스)로써 _CRI-O_ 를 설치함, _docker_ 필요 없음!
  - 컨테이너 관리 도구 CLI로 _podman_ 설치를 추천함, `apt install podman` 으로 설치 가능
- CNI(Container Network Interface, 컨테이너 네트워크 인터페이스)로써 _Flannel_ 를 설치함

## 단계별 설명

### 모든 노드에서 실행할 스크립트

#### 1. `all-01-kernel.sh`

- 필요한 커널들을 활성화

#### 2. `all-02-cri.sh`

- _CRI-O_ 설치
- **OS 버전과 쿠버네티스 버전을 확인해야함**
  - 현재 지원 OS 최신버전 `xUbuntu_22.04`
  - 현재 지원 k8s 최신버전 `1.26`
  - 스크립트 파일의 6, 7번째 줄을 아래와 같은 형식으로 수정

      ```bash
      export OS=xUbuntu_22.04
      export VERSION=1.26
      ```

#### 3. `all-03-k8s-tools.sh`

- 쿠버네티스 CLI 도구들을 설치
- **쿠버네티스 버전을 확인해야 함**
  - 현재 최신 버전은 1.26.0-00
  - 스크립트 파일의 6번째 줄을 아래와 같은 형식으로 수정

      ```bash
      export K8S_VERSION=1.26.0-00
      ```

### Control-Plane(컨트롤 플레인)에서만 실행

#### 1. `cp-01-kubeadm-init.sh`

- 쿠버네티스 클러스터 초기화를 시작시킴
- 특별히 사용해야 할 IP 주소가 있다면, `--apiserver-advertise-address`, `--control-plane-endpoint` 옵션을 추가해야 함
  - 참조: <https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/#options>
- 아마도 5분 정도 소요
- 실행된 후 화면에 출력을 잘 볼것. 아래 두 가지를 위한 스크립트가 표시될 것임
  - 사용자가 클러스터에 접속할 수 있도록 만들어 주는 스크립트
  - 워커 노드를 클러스터에 Join 시키는 스크립트, **토큰(비밀번호 개념)이 있기 때문에 잘 복사해둘 것**
- 설치 후 로그(`journalctl`)에서 kubelet이 CRI 소켓을 못찾고 있다면, 올바른 방법으로 클러스터를 리셋(`kubeadm reset`) 후 `--cri-socket` 을 추가해서 다시 클러스터 초기화를 할 것

#### 2. `cp-02-kubeconfig.sh`

- 사용자가 클러스터에 접속할 수 있도록 만들어 주는 스크립트

#### 3. `cp-03-flannel.sh`

- _Flannel_ CNI를 적용

## 스크립트를 적용한 후에 할 것

1. 워커 노드를 클러스터에 Join, 아까 클러스터 초기화 후에 얻은 스크립트를 활용하기
2. 노드간 통신에 이용할 IP 주소를 따로 설정해야 한다면, _*수동으로*_ kubelet 설정파일을 수정해야 함
   1. kubelet 설정파일 `/etc/systemd/system/kubelet.service.d/10-kubelet.conf` 의 맨 마지막줄에 `--node-ip={ip}` 옵션 추가

---

- 필요한 내용 있으면 오윤석에게 물어보기
- 찾아보고 리눅스에 익숙해 져야 공부가 됨, 영어도 잘 읽도록...

## 클러스터를 재배포(재설치) 할 때 주의할 점

### 몇몇 파일은 수동으로 파일을 지우거나 수정해야 함

`kubeadm reset` 을 실행시키더라도, 몇가지 파일은 삭제가 안됨, 특히 kubelet 설정 파일이 그대로 남아있음

- `/etc/systemd/system/kubelet.service.d`
- `/opt/cni/net.d`

### 몇가지 툴 (kubelet, CRI) 은 재설치하더라도 설정파일을 생성하지 못함

설정파일을 삭제한 뒤라면 몇몇 파일은 수동으로 작성해 주어야 함

- kubelet
  - `/etc/systemd/system/kubelet.service.d/10-kubelet.conf`
  - Refer this link to get the default config: <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/kubelet-integration/>
- CRI
  - `/etc/containers/policy.json`
  - Refer this link to get the default config: <https://insights-core.readthedocs.io/en/latest/shared_parsers_catalog/containers_policy.html>
