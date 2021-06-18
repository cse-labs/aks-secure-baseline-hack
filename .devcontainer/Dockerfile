FROM mcr.microsoft.com/vscode/devcontainers/universal:1

# install packages
RUN export DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get update && \
    sudo apt-get -y install --no-install-recommends apt-utils dialog apt-transport-https ca-certificates && \
    sudo apt-get -y install --no-install-recommends curl git wget nano bash-completion software-properties-common make jq httpie iputils-ping

# install k9s, github cli, jp and fluxctl
RUN sudo curl -Lo ./k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.24.2/k9s_Linux_x86_64.tar.gz && \
    sudo mkdir k9s && \
    sudo tar xvzf k9s.tar.gz -C ./k9s && \
    sudo mv ./k9s/k9s /usr/local/bin/k9s && \
    sudo rm -rf k9s.tar.gz k9s && \
    VERSION=$(curl -i https://github.com/jmespath/jp/releases/latest | grep "location: https://github.com/" | rev | cut -f 1 -d / | rev | sed 's/\r//') && \
    sudo wget https://github.com/jmespath/jp/releases/download/$VERSION/jp-linux-amd64 -O /usr/local/bin/jp && \
    sudo chmod +x /usr/local/bin/jp && \
    sudo wget https://github.com/cli/cli/releases/download/v1.10.3/gh_1.10.3_linux_amd64.deb && \
    sudo dpkg -i gh_1.10.3_linux_amd64.deb && \
    sudo rm gh_1.10.3_linux_amd64.deb && \
    kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null && \
    sudo curl -L https://github.com/fluxcd/flux/releases/download/1.14.2/fluxctl_linux_amd64 -o /usr/local/bin/fluxctl && \
    sudo chmod +x /usr/local/bin/fluxctl && \
    sudo apt-get install -f

# create directories, update .bashrc, config git
RUN mkdir -p $HOME/.ssh && \
    mkdir -p $HOME/.kube && \
    mkdir -p $HOME/bin && \
    mkdir -p $HOME/.local/bin && \
    mkdir -p $HOME/.k9s && \
    mkdir -p $HOME/go/src && \
    mkdir -p $HOME/.dotnet/tools && \
    echo "" >> $HOME/.bashrc && \
    echo "export PATH=$PATH:$HOME/.local/bin:$HOME/.dotnet/tools" >> $HOME/.bashrc && \
    echo "alias k='kubectl'" >> $HOME/.bashrc && \
    echo "alias kga='kubectl get all'" >> $HOME/.bashrc && \
    echo "alias kgaa='kubectl get all --all-namespaces'" >> $HOME/.bashrc && \
    echo "alias kaf='kubectl apply -f'" >> $HOME/.bashrc && \
    echo "alias kdelf='kubectl delete -f'" >> $HOME/.bashrc && \
    echo "alias kl='kubectl logs'" >> $HOME/.bashrc && \
    echo "alias kccc='kubectl config current-context'" >> $HOME/.bashrc && \
    echo "alias kcgc='kubectl config get-contexts'" >> $HOME/.bashrc && \
    echo "alias kj='kubectl exec -it jumpbox -- bash -l'" >> $HOME/.bashrc && \
    echo "alias kje='kubectl exec -it jumpbox -- '" >> $HOME/.bashrc && \
    echo "export FLUX_FORWARD_NAMESPACE=flux-cd" >> $HOME/.bashrc && \
    echo "export GO111MODULE=on" >> $HOME/.bashrc && \
    echo "alias ipconfig='ip -4 a show eth0 | grep inet | sed \"s/inet//g\" | sed \"s/ //g\" | cut -d / -f 1'" >> $HOME/.bashrc && \
    echo 'export PIP=$(ipconfig | tail -n 1)' >> $HOME/.bashrc && \
    echo 'complete -F __start_kubectl k' >> $HOME/.bashrc && \
    dotnet tool install -g --version 2.0.0-beta2 webvalidate && \
    git config --global core.whitespace blank-at-eol,blank-at-eof,space-before-tab && \
    git config --global pull.rebase false && \
    git config --global init.defaultbranch main && \
    git config --global core.pager more
