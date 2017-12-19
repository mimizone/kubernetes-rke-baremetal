FROM tensorflow/tensorflow:latest-gpu

MAINTAINER alex@milowski.com

RUN curl -LO http://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh
RUN bash Miniconda-latest-Linux-x86_64.sh -p /miniconda -b
RUN rm Miniconda-latest-Linux-x86_64.sh
ENV PATH=/miniconda/bin:${PATH}
RUN conda update -y conda

RUN pip install --upgrade pip
RUN pip install numpy

RUN conda create -n py36 -y python=3.6
RUN bash -c "source activate py36; pip install numpy ipython ipykernel; python -m ipykernel install --name Python3.6"
