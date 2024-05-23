FROM apache/airflow:custom-bullseye
USER root

# Install Nvidia CUDA and drivers
RUN add-apt-repository contrib && \
    apt update && \
    apt install -y build-essential linux-headers-$(uname -r) wget && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/debian11/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i ./cuda-keyring_1.1-1_all.deb && \
    apt update && \
    apt install -y cuda-toolkit-12-5 cuda-drivers-555 nvidia-driver-555-open && \
    echo "Nvidia driver installed"

# linux-headers-$(uname -r)
    # apt-key del 7fa2af80 || true && \
