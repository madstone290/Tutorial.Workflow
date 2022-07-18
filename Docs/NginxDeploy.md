## Self-contained vs Framework dependent
- {AppName}.runtimeconfi.json 파일이 없으면 Self-contained app이라고 판단한다.


## Configurations

## EndPoints
| EndPoint | 내용 | 비고|
|--|--|--|
| localhost:33000 | blue web | |
| localhost:33100 | blue api | |
| localhost:33200 | blue color check | 라이브 서버 컬러확인용 끝점 |
| localhost:34000 | blue staing-web  | blue가 live일때 staing-web 끝점. green의 live web 끝점과 동일하다. |
| localhost:34100 | blue staging-api | blue가 live일때 staing-api 끝점. green의 live api 끝점과 동일하다.|
| localhost:34000 | green web | |
| localhost:34100 | green api | |
| localhost:34200 | green color check | 라이브 서버 컬러확인용 끝점 |
| localhost:33000 | green staing-web  | green이 live일때 staing-web 끝점. blue의 live web 끝점과 동일하다. |
| localhost:33100 | green staging-api | green이 live일때 staing-api 끝점. blue의 live api 끝점과 동일하다. |


## Files
|경로|내용|비고|
|--|--|--|
| ~/workflow/publish | 외부에서 새 게시물을 전송할 디렉토리. 디렉토리 파일들을 blue/green 컬러에 맞는 배포 디렉토리로 이동시킨다. | 디렉토리 |
| ~/workflow/blue/api | blue api 파일 | |
| ~/workflow/blue/web | blue web 파일 | |
| ~/workflow/green/api | green api 파일 | |
| ~/workflow/green/web | green web 파일 | |
| /etc/nginx/conf.d/workflow-blue-color.inc | blue 서버 업스트림 컬러 변수. /upstream-color 끝점에 사용된다.  | |
| /etc/nginx/conf.d/workflow-green-color.inc | green 서버 업스트림 컬러 변수. /upstream-color 끝점에 사용된다. | |
| /etc/nginx/conf.d/workflow-upstream.inc| 업스트림(blue or green) 서버 nginx 설정 링크 | |
| /etc/nginx/sites-available/workflow-blue.conf| blue 서버 nginx 설정 | |
| /etc/nginx/sites-available/workflow-green.conf| green 서버 nginx 설정 |
| /etc/nginx/sites-available/workflow-live.conf| live 서버 nginx 설정 | |
| /etc/nginx/sites-available/workflow-staging.conf| staging 서버 nginx 설정 | |
| /etc/nginx/sites-enabled/workflow-green.conf| blue 서버 nginx 설정 링크 | |
| /etc/nginx/sites-enabled/workflow-live.conf| live 서버 nginx 설정 링크 |  |

### /etc/nginx/conf.d/workflow-blue-color.inc
```
set $upstream_color "blue";
```

### /etc/nginx/conf.d/workflow-green-color.inc
```
set $upstream_color "green";
```

### /etc/nginx/sites-available/workflow-blue.conf
blue서버가 live일때의 서버 주소를 지정한다.
```
upstream workflow-frontend {
    server localhost:33000;
}

upstream workflow-backend {
    server localhost:33100;
}

upstream workflow-frontend-staging {
    server localhost:34000;
}

upstream workflow-backend-staging {
    server localhost:34100;
}
```

### /etc/nginx/sites-available/workflow-green.conf
green서버가 live일때의 서버 주소를 지정한다.
```
upstream workflow-frontend {
    server localhost:34000;
}

upstream workflow-backend {
    server localhost:34100;
}

upstream workflow-frontend-staging {
    server localhost:33000;
}

upstream workflow-backend-staging {
    server localhost:33100;
}
```

### /etc/nginx/sites-available/workflow-live.conf|
live서버 설정. blue/green 중 활성화된 서버의 설정을 적용한다.
```
server {
    listen 80;
    server_name tutorial-workflow.duckdns.org;

    location / {
        # frontend upstream 사용. blue/green 중 활성화된 값을 적용한다.
        proxy_pass         http://workflow-frontend;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }

    location /api {
        # backend upstream 사용. blue/green 중 활성화된 값을 적용한다.
        proxy_pass         http://workflow-backend;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }
}
```

### /etc/nginx/sites-available/workflow-staging.conf|
staging서버 설정. blue/green 중 활성화된 서버의 설정을 적용한다.
```
server {
    listen 80;
    server_name staging.tutorial-workflow.duckdns.org;

    location / {
        # frontend-staging upstream 사용. blue/green 중 활성화된 값을 적용한다.
        proxy_pass         http://workflow-frontend-staging;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }
    location /api {
        # backend-staging upstream 사용. blue/green 중 활성화된 값을 적용한다.
        proxy_pass         http://workflow-backend-staging;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }
}
```

### /etc/systemd/system/workflow-blue.service
blue서버 구동을 위한 시스템 서비스
WorkingDirectory, ExecStart, Environment=ASPNETCORE_URLS 값 확인
```
[Unit]
Description=Workflow blue api

[Service]
WorkingDirectory=/home/ubuntu/workflow/blue/api
ExecStart=/usr/bin/dotnet WorkflowApi.dll UpStreamColor=blue
Restart=always
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=workflow blue api
User=www-data
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=ASPNETCORE_URLS=http://localhost:33100
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target
```

### /etc/systemd/system/workflow-green.service
green서버 구동을 위한 시스템 서비스
WorkingDirectory, ExecStart, Environment=ASPNETCORE_URLS 값 확인
```
[Unit]
Description=Workflow green api

[Service]
WorkingDirectory=/home/ubuntu/workflow/green/api
ExecStart=/usr/bin/dotnet WorkflowApi.dll UpStreamColor=green
Restart=always
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=workflow green api
User=www-data
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=ASPNETCORE_URLS=http://localhost:34100
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target
```



### blue/green 활성화 상태 변경
활성화된 컬러에 맞는 링크경로를 변경한다.
/etc/nginx/sites-enabled/workflow-upstream.conf의 링크경로를 blue or green으로 변경한다.
/etc/nginx/conf.d/workflow-upstream-color.inc 링크경로를 blue or green으로 변경한다.
```
# blue를 활성화 상태로 변경
sudo ln -sf /etc/nginx/sites-available/workflow-blue.conf /etc/nginx/sites-enabled/workflow-upstream.conf

# 파일을 이용한 upstream color 확인시에 사용한다.
# http 응답을 통해 upstream color를 확인할 경우 사용하지 않는다.
# sudo ln -sf /etc/nginx/conf.d/workflow-blue-color.inc /etc/nginx/conf.d/workflow-upstream-color.inc

# green을 활성화 상태로 변경
sudo ln -sf /etc/nginx/sites-available/workflow-green.conf /etc/nginx/sites-enabled/workflow-upstream.conf

# 파일을 이용한 upstream color 확인시에 사용한다.
# http 응답을 통해 upstream color를 확인할 경우 사용하지 않는다.
#sudo ln -sf /etc/nginx/conf.d/workflow-green-color.inc /etc/nginx/conf.d/workflow-upstream-color.inc

# 설정 리로드
sudo systemctl reload nginx.
```
