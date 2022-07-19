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
| ~/workflow/api/publish | 외부에서 새 게시물을 전송할 디렉토리. 디렉토리 파일들을 blue/green 컬러에 맞는 배포 디렉토리로 이동시킨다. | 디렉토리 |
| ~/workflow/api/blue | blue api 파일 | |
| ~/workflow/api/green | green api 파일 | |
| ~/workflow/web/blue | blue web 파일 | |
| ~/workflow/web/green | green web 파일 | |
| /etc/nginx/conf.d/workflow-blue-color.inc | blue 서버 업스트림 컬러 변수. /upstream-color 끝점에 사용된다.  | |
| /etc/nginx/conf.d/workflow-green-color.inc | green 서버 업스트림 컬러 변수. /upstream-color 끝점에 사용된다. | |
| /etc/nginx/conf.d/workflow-upstream.inc| 업스트림(blue or green) 서버 nginx 설정 링크 | |
| /etc/nginx/sites-available/workflow-api-blue.conf| api blue 서버 nginx 설정 | |
| /etc/nginx/sites-available/workflow-api-green.conf| api green 서버 nginx 설정 |
| /etc/nginx/sites-available/workflow-api-live.conf| api live 서버 nginx 설정 | |
| /etc/nginx/sites-available/workflow-api-staging.conf| api staging 서버 nginx 설정 | |
| /etc/nginx/sites-available/workflow-web-blue.conf| web blue 서버 nginx 설정 | |
| /etc/nginx/sites-available/workflow-web-green.conf| web green 서버 nginx 설정 |
| /etc/nginx/sites-available/workflow-web-live.conf| web live 서버 nginx 설정 | |
| /etc/nginx/sites-available/workflow-web-staging.conf| web staging 서버 nginx 설정 | |

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
