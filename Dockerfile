FROM codercom/code-server
ENV JULIA_VERSION=1.3.1 \
    R_VERSION=3.6.2

# Julia
RUN cd /usr/local/bin \
    && sudo mkdir julia_dir \
    && cd julia_dir \
    && sudo wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz \
    && echo "faa707c8343780a6fe5eaf13490355e8190acf8e2c189b9e7ecbddb0fa2643ad *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - \
    && sudo tar fxz julia-${JULIA_VERSION}-linux-x86_64.tar.gz \
    && sudo rm -R julia-${JULIA_VERSION}-linux-x86_64.tar.gz \
    && cd .. \
    && sudo ln -s julia_dir/julia-${JULIA_VERSION}/bin/julia julia \
    && sudo wget https://github.com/julia-vscode/julia-vscode/releases/download/v0.14.0-beta.2/language-julia-0.14.0-beta.2.vsix \
    && code-server --install-extension language-julia-0.14.0-beta.2.vsix \
    && sudo rm language-julia-0.14.0-beta.2.vsix
# Python
RUN cd /usr/local/bin \
    && sudo mkdir miniconda3 \
    && cd miniconda3 \
    && sudo wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && echo "bfe34e1fa28d6d75a7ad05fd02fa5472275673d5f5621b77380898dee1be15d2 *Miniconda3-latest-Linux-x86_64.sh" | sha256sum -c - \
    && bash Miniconda3-latest-Linux-x86_64.sh -bfp \
    && sudo ln -s ~/miniconda3/bin/conda /usr/local/bin \
    && sudo ln -s ~/miniconda3/bin/python /usr/local/bin
# R
RUN echo "set debconf/frontend noninteractive" | DEBIAN_FRONTEND=noninteractive sudo debconf-communicate \
    && sudo apt-get update \
    && sudo apt-get -yq --fix-missing install \
    r-base \
    r-base-dev

RUN sudo chmod 777 /usr/local/lib/R/site-library \
    && sudo Rscript -e "install.packages(c('littler', 'docopt'))" \
    && sudo ln -s /usr/local/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
    && sudo ln -s /usr/local/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
    && sudo ln -s /usr/local/lib/R/site-library/littler/bin/r /usr/local/bin/r \
    && install2.r lmerTest \
    sudo chmod 771 /usr/local/lib/R/site-library
