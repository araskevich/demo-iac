# sudo docker build . -t k8s-utilities:v0.1
# sudo docker tag k8s-utilities:v0.1 docker-registry.localdomain:80/devops/k8s-utilities:v0.1
# sudo docker push docker-registry.localdomain:80/devops/k8s-utilities:v0.1

FROM alpine:latest

WORKDIR /usr/local/bin

# apk add gcompat to run binary
RUN apk add libc6-compat

COPY /usr/local/bin/helm .
COPY /usr/local/bin/kubectl .
CMD ["pwd"]
