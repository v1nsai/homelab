#!/bin/bash

set -e
source projects/airflow/secrets.env

if [ -z "$USER_EMAIL" ] || [ -z "$USER_NAME" ] || [ -z "$USER_FIRSTNAME" ] || [ -z "$USER_LASTNAME" ]; then
    echo "Please set USER_EMAIL, USER_NAME, USER_FIRSTNAME and USER_LASTNAME in projects/airflow/secrets.env"
    exit 1
fi

# helm repo add airflow-stable https://airflow-helm.github.io/charts
# helm repo add apache-airflow https://airflow.apache.org
# helm repo update

echo "Configuring users, auth and encryption..."
if ! kubectl get secret airflow-auth -n airflow &> /dev/null; then
    echo "Creating secret airflow-auth..."
    USER_PASSWORD=$(openssl rand -base64 20)
    AIRFLOW__CORE__FERNET_KEY=$(python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")
    kubectl create secret generic airflow-auth \
        --from-literal=auth-username="$USER_NAME" \
        --from-literal=auth-password="$USER_PASSWORD" \
        --from-literal=auth-email="$USER_EMAIL" \
        --from-literal=auth-firstname="$USER_FIRSTNAME" \
        --from-literal=auth-lastname="$USER_LASTNAME" \
        --from-literal=fernet-key="$AIRFLOW__CORE__FERNET_KEY" \
        --from-literal=webserver-secret-key="$WEB_SERVER_SECRET_KEY" \
        --namespace airflow
else
    echo "Secret airflow-auth already exists."
    AIRFLOW__CORE__FERNET_KEY="$(kubectl get secret airflow-auth -n airflow -o jsonpath='{.data.fernet-key}' | base64 -d)"
    USER_PASSWORD="$(kubectl get secret airflow-auth -n airflow -o jsonpath='{.data.auth-password}' | base64 -d)"
fi

# echo "Building custom airflow image with nvidia support..."
AIRFLOW_VERSION=2.8.3
AIRFLOW_REPO='apache/airflow'
AIRFLOW_TAG="$AIRFLOW_VERSION"
# BUILDX_EXPERIMENTAL=1 DOCKER_BUILDKIT=1 docker build -t $AIRFLOW_REPO:$AIRFLOW_TAG -f projects/airflow/Dockerfile projects/airflow
# K8S_CLUSTER_SSH_NAMES=( "bigrig" "ASUSan" "oppenheimer" )
# for i in "${K8S_CLUSTER_SSH_NAMES[@]}"
# do
#     echo "Copying airflow image to $i..."
#     docker save $AIRFLOW_REPO:$AIRFLOW_TAG | bzip2 | pv | ssh $i docker load
# done

# echo "Removing airflow before installing..."
# helm delete -n airflow airflow || true
# kubectl delete all --all -n airflow || true
# kubectl delete pvc --all -n airflow || true
# sleep 10

echo "Installing Airflow..."
# helm repo add apache-airflow https://airflow.apache.org
# helm repo update
helm upgrade --install airflow apache-airflow/airflow \
    --namespace airflow \
    --create-namespace \
    --set images.airflow.repository="$AIRFLOW_REPO" \
    --set images.airflow.tag="$AIRFLOW_TAG" \
    --set airflowVersion="${AIRFLOW_VERSION}" \
    --set workers.resources.limits."nvidia\.com/gpu"=1 \
    --set webserver.defaultUser.username="${USER_NAME}" \
    --set webserver.defaultUser.password="${USER_PASSWORD}" \
    --set webserver.defaultUser.email="${USER_EMAIL}" \
    --set webserver.defaultUser.firstName="${USER_FIRSTNAME}" \
    --set webserver.defaultUser.lastName="${USER_LASTNAME}" \
    --set webserver.service.type=LoadBalancer \
    --set webserverSecretKeyName=airflow-auth \
    --set workers.waitForMigrations.enabled=true \
    --set config.core.load_examples="True" #\
    # --values projects/airflow/apache-airflow-values.yaml
    
# # git clone git@github.com:apache/airflow.git projects/airflow/airflow || true
# sed -i 's/debian/ubuntu/g' projects/airflow/airflow/Dockerfile
# sed -i 's/DEBIAN/UBUNTU/g' projects/airflow/airflow/Dockerfile
# sed -i 's/apt-get install -y --no-install-recommends/DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends/g' projects/airflow/airflow/Dockerfile
# sed -i 's/COPY <<\"EOF\"/COPY --chmod=777 <<\"EOF\"/g' projects/airflow/airflow/Dockerfile
# sed -i 's/USER .*/USER root\n/g' projects/airflow/airflow/Dockerfile
# sed -i 's/SHELL .*$/SHELL \[ \"\/bin\/bash\", \"-c\" \]/g' projects/airflow/airflow/Dockerfile
# sed -i '/^RUN --mount=type=cache.*\\$/ s/\\$/; \\/g' projects/airflow/airflow/Dockerfile
# sed -i 's/ ;/;/g' projects/airflow/airflow/Dockerfile
# sed -i 's/,uid=\$\{AIRFLOW_UID\};/;/g' projects/airflow/airflow/Dockerfile
# BUILDX_EXPERIMENTAL=1 DOCKER_BUILDKIT=1 docker build -t doctor-ew/airflow:custom-cuda -f projects/airflow/airflow/Dockerfile projects/airflow/airflow --build-arg PYTHON_BASE_IMAGE=nvidia/cuda:custom-python --invoke /bin/bash

# BUILDX_EXPERIMENTAL=1 DOCKER_BUILDKIT=1 docker build -t doctor-ew/airflow:custom-cuda -f projects/airflow/Dockerfile.airflow-cuda projects/airflow --invoke /bin/bash

