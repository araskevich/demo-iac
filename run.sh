#!/usr/bin/env bash

#################  deploy_k8s_vm  ####################

function stage_1:deploy-vm {
  # ls -l ~/.terraform.d/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.14/linux_amd64/terraform-provider-libvirt_v0.6.14
  # ls -l ~/.terraform.d/plugins/registry.terraform.io/hashicorp/template/2.2.0/linux_amd64/terraform-provider-template_v2.2.0
  cd terraform/
  sudo terraform init
  # sudo terraform plan
  sudo terraform apply
  # sudo terraform apply -auto-approve
  cd -
}

function stage_2:configure-vm {
  cd ansible/
  sudo su devops
  ansible-playbook site.yml
  exit
  cd -
}

function stage_3:deploy-app {
  echo example: stage_3:deploy-app 
}

function stage_4:destroy-vm {
  cd terraform/
  sudo terraform destroy
  cd -
}

#####################################################

#################  deploy_k8s  ######################
function deploy_k8s_1:k8s-ingress-controller-nginx {
  kubectl apply -f k8s-ingress-monitoring/ingress-controller-nginx.yaml
  # kubectl patch svc ingress-nginx-controller -n ingress-nginx -p '{"spec": {"type": "LoadBalancer", "externalIPs":["192.168.122.11"]}}'
}

function deploy_k8s_2:k8s-metrics-server {
  kubectl apply -f k8s-ingress-monitoring/metrics-server.yaml
}

function deploy_k8s_3:k8s-dashboard {
  kubectl apply -f k8s-ingress-monitoring/k8s-dashboard.yaml -f k8s-ingress-monitoring/kubedash-ingress.yaml
}

function deploy_k8s_3:k8s-dashboard-create-account {
  kubectl create serviceaccount dashboard -n default
  kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboard
  kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode
}

function deploy_k8s_3:k8s-dashboard-tocken-show {
  kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode
}

function deploy_k8s_4:k8s-docker-registry-prep {
  ssh devops@192.168.122.11  "sudo mkdir -p /mnt/data/docker-registry/ && sudo ls -l /mnt/data/docker-registry/"

  mkdir -p /registry/{auth,certs}
  cd /registry
  docker run --rm \
    --entrypoint htpasswd \
    httpd:2 -Bbn testuser testpassword > auth/htpasswd
  
  kubectl create secret generic docker-registry-auth-secret --from-file=/registry/auth/htpasswd
  # kubectl create secret tls certs-secret --cert=/registry/certs/tls.crt --key=/registry/certs/tls.key
  # rm -rf /registry
}

function deploy_k8s_4:k8s-docker-registry {
  kubectl apply -f utilities/k8s-docker-registry/namespace.yaml \ 
                -f utilities/k8s-docker-registry/serviceAccount.yaml \
                -f utilities/k8s-docker-registry/volume.yaml \
                -f utilities/k8s-docker-registry/service.yaml \
                -f utilities/k8s-docker-registry/ingress.yaml \
                -f utilities/k8s-docker-registry/deployment.yaml
}

function deploy_k8s_4:k8s-docker-registry-default-regcred {
  kubectl -n default create secret docker-registry regcred \
    --docker-server="docker-registry.localdomain:80" \
    --docker-username="testuser" \
    --docker-password="testpassword" \
    --docker-email=devops@localdomain.com
  
  # kubectl create secret docker-registry regcred \
  #   --docker-server=<your-registry-server> \
  #   --docker-username=<your-name> \
  #   --docker-password=<your-pword> \
  #   --docker-email=<your-email>
}

function deploy_k8s_5:k8s-jenkins-prep {
  ssh devops@192.168.122.11  "sudo mkdir -p /mnt/data/jenkins/ && sudo ls -l /mnt/data/jenkins/"
}

function deploy_k8s_5:k8s-jenkins {
  kubectl apply -f utilities/k8s-jenkins/namespace.yaml \ 
                -f utilities/k8s-jenkins/serviceAccount.yaml \
                -f utilities/k8s-jenkins/volume.yaml \
                -f utilities/k8s-jenkins/service.yaml \
                -f utilities/k8s-jenkins/ingress.yaml \
                -f utilities/k8s-jenkins/deployment.yaml
}

function deploy_k8s_5:k8s-jenkins-init-passwd {
  echo example: kubectl -n jenkins port-forward service/jenkins-service 8080:8080
  echo example: kubectl -n jenkins logs pods/jenkins-559d8cd85c-zgbhl
}

function deploy_k8s_5:k8s-jenkins-docker-regcred {
  kubectl -n jenkins create secret docker-registry regcred \
    --docker-server="docker-registry.localdomain:80" \
    --docker-username="testuser" \
    --docker-password="testpassword" \
    --docker-email=devops@localdomain.com
}

function create_dns:local {   
   echo "# update /etc/hosts"
   echo 192.168.122.11 kubedash.localdomain
   echo 192.168.122.11 jenkins.localdomain
   echo 192.168.122.11 docker-registry.localdomain
   echo 192.168.122.11 web-app.localdomain
   echo 192.168.122.11 api-server.localdomain
}

function k8s-utilities-image {
  ls -l ./utilities/k8s-utilities-image/Dockerfile
  cd ./utilities/k8s-utilities-image/
  sudo docker build . -t k8s-utilities:v0.1
  cd -
  echo example of Jenkinsfile with kaniko and k8s-jenkins-jnlp-agent-docker-image podTemplate
  ls -l ./utilities/k8s-utilities-image/Jenkinsfile
}

#####################################################

#################  deploy_k8s_app  ##################

function deploy_k8s_app_1:api-server {
  cd ./blue-green-app/deploy/helm-charts/
  # helm install api-server ./api-server/ -n default
  # helm upgrade --install api-server ./api-server/ --set image.tag=6 --set appColor="green" -n default
  # helm upgrade --install api-server ./api-server/ --set image.tag=6 --set appColor="blue" -n default
  helm upgrade --install api-server ./api-server/ --set image.tag=v0.1 -n default
  sleep 10 && kubectl get all -n default -l app.kubernetes.io/name=api-server
  cd -
}

function deploy_k8s_app_2:web-app {
  cd ./blue-green-app/deploy/helm-charts/
  # helm install web-app ./web-app/ -n default 
  helm upgrade --install web-app ./web-app/ --set image.tag=v0.1 -n default
  sleep 10 && kubectl get all -n default -l app.kubernetes.io/name=web-app
  cd -
}

#####################################################

function kubectl:completion {
  # sudo apt install bash-completion
  source <(kubectl completion bash)
  echo "source <(kubectl completion bash)" >> ~/.bashrc
}

function virsh:status {
  sudo virsh list --all
  sudo virsh pool-list --all
  sudo virsh net-list
  sudo virsh net-dumpxml default
  sudo virsh net-dhcp-leases default
}

function useful-cmd {
  echo example: sudo wget "http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
  echo example: sudo qemu-img resize CentOS-7-x86_64-GenericCloud.qcow2 20G
}

function dependency {
    TERRAFORM_VERSION=$(terraform version | head -n 1 | grep Terraform | cut -d " " -f 2)

    if [ "$TERRAFORM_VERSION" != "" ]; then
        printf "[INFO] Terraform is installed, version: %s\n" "$TERRAFORM_VERSION"
    else
        printf "[CRIT] Terraform is not installed\n"
    fi

    HELM_VERSION=$(helm version | head -n 1 | grep Version | cut -d '"' -f 2)

    if [ "$HELM_VERSION" != "" ]; then
        printf "[INFO] HELM is installed, version: %s\n" "$HELM_VERSION"
    else
        printf "[CRIT] HELM is not installed\n"
    fi

    ANSIBLE_VERSION=$(ansible --version | head -n 1 | grep ansible | tr -d "\[\|\]" | cut -d " " -f 2,3)

    if [ "$ANSIBLE_VERSION" != "" ]; then
        printf "[INFO] Ansible is installed, version: %s\n" "$ANSIBLE_VERSION"
    else
        printf "[CRIT] Ansible is not installed\n"
    fi

    # virsh --version
    # libvirtd --version
    # kvm --version
    # systemctl is-active libvirtd.service
    # active
}

function help {
  printf "%s <task> [args]\n\nTasks:\n" "${0}"

  compgen -A function | grep -v "^_" | cat -n

  printf "\nExtended help:\n  Each task has comments for general usage\n"
}

TIMEFORMAT=$'\nTask completed in %3lR'
time "${@:-help}"
# eval ${@:-help}
