docker_image=$1
## step 2, 准备/usr/cuda_files,这种方式可以避免容器中安装cuda驱动
prepare_nvidia_driver() {
  ## this script is provided by baoxinqi@4paradigm.com!
  TARGET_DIR="/usr/cuda_files"
  mkdir -p $TARGET_DIR
  echo "Try install cuda dependent libraries to $TARGET_DIR"
  INFRASTRUCTURE="x86-64"
  LIBCUDA_PATH=$(ldconfig -p | grep libcuda | grep $INFRASTRUCTURE | awk '{print $4}' | tail -n 1)
  LIBNVIDIALOADER_PATH=$(ldd $LIBCUDA_PATH | grep libnvidia | awk '{print $3}' | tail -n 1)
  if [ $LIBCUDA_PATH == "" ]; then
      echo "Cannot find libcuda.so in your environment"
      exit 1
  else
      echo "Find libcuda at $LIBCUDA_PATH"
  fi

  LIBCUDA_DIR=$(dirname $LIBCUDA_PATH)
  LIBNVIDIALOADER_DIR=$(dirname $LIBNVIDIALOADER_PATH)
  echo "Copy library libcuda* from $LIBCUDA_DIR to $TARGET_DIR..."
  cp -v $LIBCUDA_DIR/libcuda* $TARGET_DIR
  echo "Copy library libnvidia* from $LIBNVIDIALOADER_DIR to $TARGET_DIR..."
  cp -v $LIBNVIDIALOADER_DIR/libnvidia* $TARGET_DIR
}

## step3, 启动镜像
run_container() {
  echo "run docker image"
  TARGET_DIR="/usr/cuda_files"
  DOCKER_IMAGE="$docker_image"
  DEV_MOUNT="--device /dev/nvidiactl:/dev/nvidiactl \
             --device /dev/nvidia-uvm:/dev/nvidia-uvm \
             --device /dev/nvidia1:/dev/nvidia0  \
             -v $TARGET_DIR:/usr/cuda_files \
             -v /usr/bin/nvidia-smi:/usr/bin/nvidia-smi \
             -v /opt/license:/root/nn-predictor-source/bin/release/license"

  name="docker_image_test6"
  #使用本机host网络，否则无法socr无法访问nnpredictor.
  docker run --net=host -it ${DEV_MOUNT} $DOCKER_IMAGE bash
  if [ $? -eq 0 ]; then
      echo "run  docker image success"
  else
      echo "run docker image failed!"
      exit 1
  fi
}

run_container