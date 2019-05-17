# down base ubuntu image from https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/10.1/base/Dockerfile
FROM ubuntu:16.04
LABEL maintainer "NVIDIA CORPORATION <cudatools@nvidia.com>"
LABEL maintainer_2="Juyeong Lee <ljy3795@gmail.com>"


###########################################################################################################
###########################################################################################################

ARG pyver=3.5
ARG rver=3.5
ARG user_nm=colin

USER root



COPY notebook.json $HOME/.jupyter/nbconfig/
COPY matplotlibrc $HOME/.config/matplotlib/
COPY fix-permissions /usr/local/bin/fix-permissions
COPY start.sh  /usr/local/bin/
COPY jupyter_notebook_config.py  /etc/jupyter/
COPY set_jupyter_pw.sh /usr/local/bin/

###########################################################################################################
###########################################################################################################


RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates apt-transport-https gnupg-curl && \
    rm -rf /var/lib/apt/lists/* && \
    NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5 && \
    NVIDIA_GPGKEY_FPR=ae09fe4bbd223a84b2ccfce3f60f4b3d7fa2af80 && \
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub && \
    apt-key adv --export --no-emit-version -a $NVIDIA_GPGKEY_FPR | tail -n +5 > cudasign.pub && \
    echo "$NVIDIA_GPGKEY_SUM  cudasign.pub" | sha256sum -c --strict - && rm cudasign.pub && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

ENV CUDA_VERSION 10.1.168

ENV CUDA_PKG_VERSION 10-1=$CUDA_VERSION-1
# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-cudart-$CUDA_PKG_VERSION \
        cuda-compat-10-1 && \
    ln -s cuda-10.1 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.1 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=396,driver<397 brand=tesla,driver>=410,driver<411"




###########################################################################################################
###########################################################################################################


###########################################################################################################
###########################################################################################################
# Setting up base files for making image

# change apt source list to kakao
RUN sed -i 's#http://archive.ubuntu.com/ubuntu/#http://mirror.kakao.com/ubuntu/#g' /etc/apt/sources.list
RUN sed -i 's#http://security.ubuntu.com/ubuntu/#http://mirror.kakao.com/ubuntu/#g' /etc/apt/sources.list

# install wget & copy wgetrc
RUN apt-get update && apt install -y gnupg
RUN apt update && apt install -y --no-install-recommends wget

RUN mkdir /root/.subversion


###########################################################################################################
## Setup on Root
###########################################################################################################
# 1-0) Setup Ubuntu basics

# install ubuntu programs
RUN apt-get update && apt-get -yq dist-upgrade && apt-get install -yq --no-install-recommends apt-utils apt-transport-https
RUN apt-get update && apt-get install -yq --no-install-recommends \
            build-essential \
            cmake \
            git \
            curl \
            vim \
            netcat-openbsd \
            telnet \
            htop \
            locales \
            sudo \
            graphviz \
            ssh \
            cron \
            bzip2 \
            openjdk-8-jdk \
            openjdk-8-jre-headless \
            ca-certificates \
            ca-certificates-java \
            fonts-liberation \
            fonts-nanum-coding \
            libjpeg-dev \
            libpng-dev \
            libsasl2-dev \
            libsasl2-modules \ 
            libcurl4-openssl-dev \
            libssl-dev \
            swig \
            software-properties-common && \
            rm -rf /var/lib/apt/lists/*

RUN  mkdir /usr/java
RUN  ln -s /usr/lib/jvm/java-8-openjdk-amd64 /usr/java/latest && \
     ln -s /usr/java/latest /usr/java/default
ENV JAVA_HOME /usr/java/default




###########################################################################################################
# 1-1) Setup Python

# add repo for install python 3.5
RUN sudo apt-get --force-yes remove python
RUN sudo apt-get autoremove && sudo apt-get autoclean

RUN sudo -E add-apt-repository ppa:jonathonf/python-${pyver} -y && \
    apt-get update

## Python Part
RUN sudo apt-get update && sudo apt-get -yq install --no-install-recommends \
    python-dev \
    python3-tk \
    python3-dev \ 
    python${pyver} \
    python${pyver}-dev \
    python${pyver}-venv && \
    apt-get -yq install --no-install-recommends libopenblas-dev curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl https://bootstrap.pypa.io/get-pip.py | python${pyver}





# ###########################################################################################################
# # 1-2) Setup R

# # add R repo
# # RUN apt-get update && \
# #     echo "deb https://cran.rstudio.org/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list && \
# #     apt-get update


# #R 커널 설치
# RUN apt-get update && \
# apt-get -y install software-properties-common && \
# apt-get clean

# RUN apt-get update && \
# add-apt-repository ppa:marutter/rrutter${rver} && \
# apt-get update && \
# apt-get -y install r-api-${rver}


# # install basic R packages
# RUN apt-get install -yq --no-install-recommends \
#     r-cran-littler \
#     r-recommended && \
#     apt-get clean \
#     && echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site \
#     && echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r \
#     && ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r \
#     && ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r \
#     && ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
#     && ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
#     && install.r docopt tidyverse dplyr ggplot2 devtools formatR remotes selectr caTools data.table car \
#     && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
#     && rm -rf /var/lib/apt/lists/*

# # RUN Rscript -e "install.packages(c('rJava', 'RJDBC'), dependencies=TRUE)"




###########################################################################################################
# 1-4) ETC 

#로케일설정
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen


# Install Tini... 간헐적 좀비 프로세스 생성 방지
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.10.0/tini && \
    echo "1361527f39190a7338a0b434bd8c88ff7233ce7b9a4876f3315c22fce7eca1b0 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

# 환경변수
ENV VENV_DIR=/opt/venv \
    SHELL=/bin/bash \
    NB_USER=${user_nm} \
    NB_UID=1000 \
    NB_GID=100 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

ENV PATH=$VENV_DIR/bin:$PATH \
    HOME=/home/$NB_USER \
    LD_LIBRARY_PATH="/usr/local/lib/:${LD_LIBRARY_PATH}"


# Create user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
# setup user account and authority
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p $VENV_DIR && \
    chown $NB_USER:$NB_GID $VENV_DIR &&\
    fix-permissions $HOME && \
    fix-permissions $VENV_DIR

RUN mkdir /home/$NB_USER/.subversion




###########################################################################################################
## Setup on User (NB_USER)
###########################################################################################################
USER $NB_USER



###########################################################################################################
# 1-0) Setup Python basic packages

#virtualenv로 개인 권한 내에서 파이썬 설치
RUN python${pyver} -m venv $VENV_DIR && \
/bin/bash -c "source $VENV_DIR/bin/activate"

# # install deep learning framework (mxnet & pytorch)
# RUN pip${pyver} install mxnet-cu100
# RUN pip${pyver} install torch torchvision
# # RUN pip${pyver} install https://download.pytorch.org/whl/cpu/torch-1.0.0-cp36-cp36m-linux_x86_64.whl && \
# #     pip${pyver} install torchvision

#install ibase python packages for machine learning
RUN pip${pyver} install --upgrade pip && pip${pyver} install setuptools --ignore-installed && \
    pip${pyver} install --no-cache-dir sasl thrift_sasl pyhive pymysql pandas scipy sklearn matplotlib seaborn

# install jupyter notebook     
RUN pip${pyver} install --no-cache-dir jupyterlab jupyter_contrib_nbextensions jupyterthemes \
    jupyter_nbextensions_configurator cython ipywidgets    




# setting jupyter notebook 
RUN jupyter nbextensions_configurator enable --user && \
    jupyter nbextension enable --py widgetsnbextension --sys-prefix --user  && \
    jupyter nbextension install https://github.com/ipython-contrib/IPython-notebook-extensions/archive/master.zip --user && \
    jupyter nbextension install https://github.com/Calysto/notebook-extensions/archive/master.zip --user && \
    rm -rf $HOME/.cache

RUN mkdir -p $HOME/.jupyter/nbconfig/ && \
    mkdir -p $HOME/.config/matplotlib/



# Set theme
# Dark theme
#RUN jt -t monokai -fs 95 -cellw 95% -T -tfs 11 -nfs 115 -f bitstream
# Light Theme
RUN jt -N -T -f firacode -tf loraserif -nf latosans -fs 95 -tfs 12 -nfs 115 -cellw 90% -t grade3


# 권한 체크 및 변경
RUN fix-permissions $VENV_DIR && fix-permissions $HOME/




# pip setting
# change default pip install path
USER root
RUN chown $NB_UID:$NB_GID $HOME/.jupyter/nbconfig/notebook.json && \
    chown $NB_UID:$NB_GID $HOME/.config/matplotlib/matplotlibrc

RUN echo 'export PYTHONUSERBASE='$HOME'/py_libs/\n'\
         'export PYTHONPATH='$HOME'/py_libs/lib/python'$pyver'/site-packages\n'\
         'export JUPYTER_PATH='$HOME'/py_libs/lib/python'$pyver'/site-packages\n'\
        #  'export R_LIBS='$HOME'/R_libs\n'\
          >>  /etc/environment

WORKDIR $HOME


# #jupyter R 커널 설치
# RUN (echo "devtools::install_github('IRkernel/IRkernel')" && \
# echo "IRkernel::installspec()") \
# | Rscript -e "source(file('stdin'))" && \
# #echo 'options(repos = c(CRAN = "http://150.6.13.63:4141/cran"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site && \
# R CMD javareconf


# Configure container startup
ENTRYPOINT ["tini", "--"]
CMD ["start-notebook.sh"]



# Add local files as late as possible to avoid cache busting
RUN fix-permissions  /etc/jupyter/ && \
    fix-permissions $HOME/.jupyter/ && \
    fix-permissions $HOME/.local/share/jupyter/kernels/

COPY ./dockerfiles_ye/custom.css $HOME/.jupyter/custom/

#time zone
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install hadoop-client
RUN apt update && sudo apt install -y hadoop-client


USER $NB_USER
RUN mkdir /home/$NB_USER/tmp