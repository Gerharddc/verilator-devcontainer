FROM ubuntu:noble
ARG VERIBLE_VERSION=v0.0-3798-ga602f072

# Install dependencies
RUN apt-get -y update && apt-get install -y \
    git help2man perl python3 make autoconf g++ flex bison ccache \
    libgoogle-perftools-dev numactl perl-doc \
    libfl2 libfl-dev \
    zlib1g zlib1g-dev \
    curl clang-format \
    gtkwave cmake \
    libspdlog-dev \
    zsh

# Install Oh My Zsh
RUN chsh -s $(which zsh)
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

# Clone and build Verilator from source using the v5.028 tag
RUN git clone https://github.com/verilator/verilator.git /tmp/verilator && \
    cd /tmp/verilator && \
    git checkout v5.028 && \
    autoconf && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    rm -rf /tmp/verilator

# Reference for setting up VSCode extension for Verible
# https://igorfreire.com.br/2023/06/18/vscode-setup-for-systemverilog-development/

# Download the precompiled binary of Verible
RUN curl -L -o verible.tar.gz https://github.com/chipsalliance/verible/releases/download/${VERIBLE_VERSION}/verible-${VERIBLE_VERSION}-linux-static-x86_64.tar.gz

# Extract the tar file
RUN tar -xzf verible.tar.gz

# Move the binary to a directory in PATH
RUN mv verible-${VERIBLE_VERSION}/bin/* /usr/local/bin/

# Clean up
RUN rm -rf verible.tar.gz verible-${VERIBLE_VERSION}

# Set the default shell to Zsh
CMD ["zsh"]
