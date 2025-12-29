FROM ubuntu:latest

# Install the timezone package with config for noninteractive install
RUN apt-get update && apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive TZ=Europe/Madrid apt-get -y install tzdata

# Update packages and install required software
RUN apt-get update && \
  apt-get install -y \
  git \
  curl \
  alsa-utils \
  fluidsynth \
  libasound2-dev \
  build-essential \
  libgmp-dev \
  libffi-dev \
  libgmp10 \
  libncurses-dev \
  pkg-config \
  libgl-dev \
  libglu1-mesa-dev \
  software-properties-common

# Install Neovim
RUN add-apt-repository -y ppa:neovim-ppa/stable && \
  apt-get update && \
  apt-get install -y neovim

# Add a local user and switch to it
RUN adduser haskell
WORKDIR /home/haskell
USER haskell

# Install Atuin
RUN curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

# Install ghcup with the required version and settings
ENV BOOTSTRAP_HASKELL_NONINTERACTIVE=1
ENV BOOTSTRAP_HASKELL_NO_UPGRADE=1
ENV BOOTSTRAP_HASKELL_GHC_VERSION=8.10.5
#ENV BOOTSTRAP_HASKELL_CABAL_VERSION=2.4.1.0
ENV BOOTSTRAP_HASKELL_INSTALL_HLS=1
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

# Add ghcup and cabal to the PATH and install the required cabal version
ENV PATH="${PATH}:/home/haskell/.ghcup/bin:/home/haskell/.cabal/bin"
RUN ghcup install cabal 2.4.1.0
RUN ghcup set cabal 2.4.1.0

# Clone and install the Haskell library for music creation
RUN git clone https://github.com/Euterpea/Euterpea2.git && \
    cd Euterpea2/ && \
    cabal v1-update && \
    cabal v1-install --allow-newer

# Clone and install the Haskell library for the book
RUN git clone https://github.com/Euterpea/HSoM.git && \
    cd HSoM/ && \
    cabal v1-install --allow-newer

# Download and setup dotfiles
RUN mkdir /home/haskell/.config
RUN git clone https://github.com/pbrandwijk/dotfiles.git
WORKDIR /home/haskell/dotfiles
RUN ./create_symlinks.sh

# Create a source folder for the code
RUN mkdir /home/haskell/src
WORKDIR /home/haskell/src
