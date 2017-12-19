#!/bin/bash

CIFAR10=../../../ml/tensorflow-models/tutorials/image/cifar10/

rm -rf cifar10
mkdir -p cifar10
cp $CIFAR10/*.py cifar10
cat <<EOF > cifar10/app.sh
#!/bin/bash
python cifar10_multi_gpu_train.py \$*
EOF
chmod +x cifar10/app.sh
cp Dockerfile cifar10
cd cifar10

docker build -t alexmilowski/tensorflow-cifar10 .
