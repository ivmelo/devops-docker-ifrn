#!/bin/bash
if [[ $UID != 0 ]]; then
    echo "Por favor, execute com sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# Parar o container do jenkins em execução.
docker stop jenkins

# Remover o container do jenkins.
docker rm jenkins

# Baixar a versão mais recente do container.
docker pull jenkins

# Recriar o container usando as opções previamente definidas.
docker run --detach -p 80:8080 -p 50000:50000 -v /srv/jenkins:/var/jenkins_home jenkins

echo "Done!"
