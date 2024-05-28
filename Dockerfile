FROM ubuntu:latest as runner
RUN useradd -ms /bin/bash user

RUN apt-get update
RUN apt-get install git curl wget -y
USER user


RUN mkdir -p "$HOME"/config
WORKDIR /home/user
RUN mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
RUN export PATH=$PATH:homebrew
WORKDIR /home/user/dotfiles
COPY . .
RUN bash ./install
