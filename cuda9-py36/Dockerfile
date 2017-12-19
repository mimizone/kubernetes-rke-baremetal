FROM nvidia/cuda:9.0-runtime

MAINTAINER alex@milowski.com

RUN apt-get update
RUN apt-get install -y build-essential libgomp1 gcc git cmake python-setuptools curl

RUN curl -LO https://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh
RUN bash Miniconda-latest-Linux-x86_64.sh -p /miniconda -b
RUN rm Miniconda-latest-Linux-x86_64.sh
ENV PATH=/miniconda/bin:${PATH}
RUN conda update -y conda

RUN pip install --upgrade pip
RUN pip install numpy tensorflow
RUN pip install http://download.pytorch.org/whl/cu90/torch-0.3.0.post4-cp27-cp27mu-linux_x86_64.whl && pip install torchvision

RUN conda create -n py35 -y python=3.5
RUN bash -c "source activate py35; pip install numpy tensorflow"
RUN bash -c "source activate py34; pip install http://download.pytorch.org/whl/cu90/torch-0.3.0.post4-cp35-cp35m-linux_x86_64.whl; pip install torchvision"

RUN conda create -n py36 -y python=3.6
RUN bash -c "source activate py36; pip install numpy tensorflow"
RUN bash -c "source activate py36; pip install http://download.pytorch.org/whl/cu90/torch-0.3.0.post4-cp36-cp36m-linux_x86_64.whl; pip install torchvision"
