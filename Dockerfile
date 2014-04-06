FROM ubuntu

# update and set encodings
RUN apt-get update
RUN locale-gen en_US en_US.UTF-8 en_CA.UTF-8
RUN dpkg-reconfigure locales

# package requirements
RUN apt-get install -y build-essential
RUN apt-get install -y redis-server
RUN apt-get install -y mysql-server
RUN apt-get

RUN mkdir ~/src

# ruby
RUN wget -O ~/src/ruby.tar.gz "http://cache.ruby-lang.org/pub/ruby/ruby-2.0.0-p353.tar.gz"
RUN tar zxvf ~/src/ruby.tar.gz -C ruby --strip-components 1
RUN cd ~/src/ruby && ./configure && make && make install
RUN gem update --system
RUN ln -s /usr/local/bin/ruby /usr/bin/ruby
