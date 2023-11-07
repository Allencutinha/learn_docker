docker build\
    --no-cache\
    --build-arg HTTP_PROXY=http://10.102.160.2:8080\
    --build-arg HTTPS_PROXY=http://10.102.160.2:8080\
    --build-arg http_proxy=http://10.102.160.2:8080\
    --build-arg https_proxy=http://10.102.160.2:8080\
    --tag kimera_vio .
