FROM codercom/code-server:3.0.2
USER root
ENV JULIA_VERSION=1.4.0 \
    JULIA_VSCODE_VERSION=0.15.19 \
    JULIA_VSCODE_FORMATTER=0.0.4 \
    VSCODE_FORMAT_VERSION=1.0.4 \
    JULIA_FORMATTER_VERSION=0.0.4 \
    ANACONDA_VERSION=4.8.2 \
    R_VERSION=3.6.3 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8

COPY assets/lacroixdavid1.vscode-format-context-menu-${VSCODE_FORMAT_VERSION}.vsix /home/coder/project/lacroixdavid1.vscode-format-context-menu-${VSCODE_FORMAT_VERSION}.vsix
COPY assets/singularitti.vscode-julia-formatter-${JULIA_FORMATTER_VERSION}.vsix /home/coder/project/singularitti.vscode-julia-formatter-${JULIA_FORMATTER_VERSION}.vsix

RUN apt-get update \
    && apt-get install -y \
    wget

# Julia ---
RUN cd /usr/local/bin \
    && sudo mkdir julia_dir \
    && cd julia_dir \
    && sudo wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz \
    && echo "30d126dc3598f3cd0942de21cc38493658037ccc40eb0882b3b4c418770ca751  julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - \
    && sudo tar fxz julia-${JULIA_VERSION}-linux-x86_64.tar.gz \
    && sudo rm -R julia-${JULIA_VERSION}-linux-x86_64.tar.gz \
    && cd .. \
    && sudo ln -s julia_dir/julia-${JULIA_VERSION}/bin/julia julia
# VS Code extensions ---
    # language-julia
RUN cd /home/coder/project/ \
    && sudo wget -q https://github.com/julia-vscode/julia-vscode/releases/download/v${JULIA_VSCODE_VERSION}/language-julia-insider-${JULIA_VSCODE_VERSION}.vsix \
    && code-server --install-extension language-julia-insider-${JULIA_VSCODE_VERSION}.vsix \
    && sudo rm language-julia-insider-${JULIA_VSCODE_VERSION}.vsix \
    # latex-input
    && code-server --install-extension yellpika.latex-input \
    # vscode-format-context-menu
    && code-server --install-extension lacroixdavid1.vscode-format-context-menu-${VSCODE_FORMAT_VERSION}.vsix \
    && sudo rm lacroixdavid1.vscode-format-context-menu-${VSCODE_FORMAT_VERSION}.vsix \
    # vscode-julia-formatter
    && code-server --install-extension singularitti.vscode-julia-formatter-${JULIA_FORMATTER_VERSION}.vsix \
    && sudo rm singularitti.vscode-julia-formatter-${JULIA_FORMATTER_VERSION}.vsix \
    # better-toml
    && code-server --install-extension bungcip.better-toml
# VS Code settings ---
COPY assets/settings.json /home/coder/.local/share/code-server/Machine
# Python ---
RUN cd /usr/local/bin \
    && sudo mkdir miniconda3 \
    && cd miniconda3 \
    && sudo wget -q https://repo.anaconda.com/miniconda/Miniconda3-py37_${ANACONDA_VERSION}-Linux-x86_64.sh \
    && echo "957d2f0f0701c3d1335e3b39f235d197837ad69a944fa6f5d8ad2c686b69df3b  Miniconda3-py37_${ANACONDA_VERSION}-Linux-x86_64.sh" | sha256sum -c - \
    && bash Miniconda3-py37_${ANACONDA_VERSION}-Linux-x86_64.sh -bfp \
    && sudo ln -s ~/miniconda3/bin/conda /usr/local/bin \
    && sudo ln -s ~/miniconda3/bin/python /usr/local/bin
# R ---
RUN echo "set debconf/frontend noninteractive" | DEBIAN_FRONTEND=noninteractive sudo debconf-communicate \
    && sudo apt-get update \
    && sudo apt-get -yq --fix-missing install \
    r-base

# RUN sudo chmod 777 /usr/local/lib/R/site-library \
#     && sudo Rscript -e "install.packages(c('littler', 'docopt'))" \
#     && sudo ln -s /usr/local/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
#     && sudo ln -s /usr/local/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
#     && sudo ln -s /usr/local/lib/R/site-library/littler/bin/r /usr/local/bin/r \
#     && install2.r lmerTest \
#     sudo chmod 771 /usr/local/lib/R/site-library
