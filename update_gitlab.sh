#!/bin/bash
if [[ $UID != 0 ]]; then
    echo "Por favor, execute com sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# Parar o container do gitlab em execução.
docker stop gitlab

# Remover o container do gitlab.
docker rm gitlab

# Baixar a versão mais recente do container.
docker pull gitlab/gitlab-ce:latest

# Recriar o container usando as opções previamente definidas.
docker run --detach \
    --hostname gitlab.ivmelo.com \
    --publish 443:443 --publish 80:80 --publish 22:22 \
    --name gitlab \
    --restart always \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest

echo "Done!"
