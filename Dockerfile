FROM ubuntu:22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

## INSTALL DEPENDENCIES
RUN apt-get update && \
    apt-get install -yq \
                    git gdb curl expect g++ make libssl-dev \
                    libxml2-dev libncurses5-dev flex bison \
                    libsctp-dev xutils-dev ant xsltproc automake perl sudo \
                    libedit2 libedit-dev

## CREATE SUDOER USER
RUN useradd --create-home --shell /bin/bash titan && \
    usermod -aG sudo titan && \
    echo "titan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

FROM base AS builder

## CLONE TITAN
WORKDIR /home/titan/

RUN git clone https://gitlab.eclipse.org/eclipse/titan/titan.core.git && \
    chown -R titan:titan /home/titan/titan.core

USER titan

# Checkout release 10.1.2
WORKDIR /home/titan/titan.core
RUN git checkout tags/10.1.2

## SET Makefile.personal
COPY --chown=titan:titan Makefile.personal .

## BUILD TITAN
RUN make install

FROM base

COPY --from=builder /home/titan/titan.core/Install /home/titan/Install

## SET UP ENV VARIABLES
ENV TTCN3_DIR=/home/titan/Install
ENV PATH=$TTCN3_DIR/bin:$PATH 

RUN export LD_LIBRARY_PATH=$TTCN3_DIR/lib:$LD_LIBRARY_PATH

COPY entrypoint.sh /home/titan/

RUN chmod +x /home/titan/entrypoint.sh && chown titan:titan /home/titan/entrypoint.sh

USER titan

WORKDIR /home/titan/data

ENTRYPOINT [ "/home/titan/entrypoint.sh" ]