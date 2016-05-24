FROM debian:jessie
MAINTAINER Daniel Mendler <mail@daniel-mendler.de>

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak
RUN touch /etc/apt/sources.list
RUN echo 'deb http://mirrors.163.com/debian jessie main non-free contrib' >> /etc/apt/sources.list
RUN echo 'deb http://mirrors.163.com/debian jessie-proposed-updates main contrib non-free' >> /etc/apt/sources.list
RUN echo 'deb http://mirrors.163.com/debian-security jessie/updates main contrib non-free' >> /etc/apt/sources.list
RUN echo 'deb http://security.debian.org jessie/updates main contrib non-free' >> /etc/apt/sources.list
RUN apt-get update && \
                       # gcc, make, etc.
    apt-get install -y --no-install-recommends \
        build-essential                        \
        python3 python3-dev python3-pip        \
        ruby ruby-dev                          \
        libzmq3 libzmq3-dev                    \
        gnuplot-nox                            \
        libgsl0-dev                            \
        # used by rbczmq
        libtool autoconf automake              \
        # used by nokogiri/publisci, see http://www.nokogiri.org/tutorials/installing_nokogiri.html
        zlib1g-dev                             \
        # used by stuff-classifier
        libsqlite3-dev                         \
        # used by rmagick
        libmagick++-dev imagemagick            \
        # used by nmatrix
        libatlas-base-dev             &&       \
    apt-get clean && \
    ln -s /usr/bin/libtoolize /usr/bin/libtool # See https://github.com/zeromq/libzmq/issues/1385

# 更新 gnuplot-nox
RUN apt-get install -y wget
RUN cd /home && wget http://jaist.dl.sourceforge.net/project/gnuplot/gnuplot/5.0.3/gnuplot-5.0.3.tar.gz && tar xf gnuplot-5.0.3.tar.gz && cd gnuplot-5.0.3 && ./configure && make && make install

RUN pip3 install "ipython[notebook]"

RUN gem sources --add https://ruby.taobao.org/ --remove https://rubygems.org/
RUN gem update --no-document --system && \
    gem install --no-document sciruby-full && \
    iruby register

ADD . /notebooks
WORKDIR /notebooks

EXPOSE 8888

# Convert notebooks to the current format
RUN find . -name '*.ipynb' -exec jupyter nbconvert --to notebook {} --output {} \;
RUN find . -name '*.ipynb' -exec jupyter trust {} \;

# CMD ipython notebook
CMD bash -l -c "iruby notebook --no-browser --ip='*' --port 8888 --notebook-dir='/notebooks'"
