# Devops IFRN

Para a disciplina de sistemas coorporativos, foi definido que o grupo 2 iria cuidar da administração dos containers gitlab e jenkins na infraestrutura. As tarefas definidas foram:

- Definir estratégia de atualização do gitlab;
- Definir estratégia de atualização do jenkins;
- Criar uma rotina que possibilite implantar a imagem do container da aplicação nos servidores de aplicação;
- Criar o registry docker das imagens dos containers contendo os builds das aplicações.;

Para replicar o ambiente, começamos adquirindo 2 VPS para o trabalho. A hospedagem selecionada foi o Digital Ocean, pela facilidade de uso e por eles cobrarem por hora.

![virtual-machines](http://i.imgur.com/U6PGiON.png)

A máquina que abriga o container gitlab, necessita de pelo menos 2 cores e 2gb de ram, devido a enorme quantidade de tarefas no background que são processadas.

Já a que abriga o container do jenkins, pode ser um pouco mais modesta.

As configurações foram:

###### Gitlab
- 2GB RAM
- 2 vcores
- 30GB SSD
- Ubuntu 16.04
- Docker 1.13.0

###### Jenkins
- 1GB RAM
- 1 vcore
- 30GB SSD
- Ubuntu 16.04
- Docker 1.13.0

(A máquina do gitlab originalmente tinha 1GB de RAM e 1 vcore, porém ela foi redimensionada após verificarmos que as especificações não dariam conta do serviço.)

As máquinas também já vieram com o docker 1.13.0 instalado por padrão.

### Instalação do Gitlab.

Para instalar o gitlab, usamos como referência a [página de documentação do gitlab para docker](https://docs.gitlab.com/omnibus/docker/README.html#where-is-the-data-stored).

Conectado a máquina por ```ssh```, executamos o seguinte comando:

```
sudo docker run --detach \
    --hostname gitlab.ivmelo.com \
    --publish 443:443 --publish 80:80 --publish 22:22 \
    --name gitlab \
    --restart always \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest
```

Em maiores detalhes:

- ```sudo docker run``` executa o container.
- ```--detach``` diz ao docker para liberar o terminal.
- ```--hostname gitlab.ivmelo.com``` diz qual endereço será usado externamente para acessar a aplicação. (Hostname).
- ```--publish 443:443 --publish 80:80 --publish 22:22``` associa (bind) as portas do container, as portas da máquina host.
- ```--restart always``` diz ao docker para reiniciar a máqiuna em caso de erro ou se ela travar.
- ```--volume``` especifica onde os dados serão armazenados na máquina host.
- ```gitlab/gitlab-ce:latest``` é a imagem docker que será baixada, caso não esteja presente no sistema.

Após isso, foi executado o comando ```docker logs gitlab --follow``` para acompanhar o resultado da instalação no terminal.

Feito isso, foi acessado a URL [http://gitlab.ivmelo.com](http://gitlab.ivmelo.com) para verificar o funcionamento do programa.

**IMPORTANTE:** Para que seja possível acessar o gitlab por SSH, a porta 22 precisa estar liberada na máquina host. Logo, antes de instalar o container do docker, nós configuramos o acesso SSH na máquina host para usar a porta 220 em vez da 22.

### Instalação do Jenkins.

Para o Jenkins, nós utilizamos a [documentação encontrada no Docker Hub](https://hub.docker.com/_/jenkins/) como referência.

O comando utilizado para baixar e iniciar a máquina virtual foi:

```
docker run --detach -p 8080:8080 -p 50000:50000 -v /srv/jenkins:/var/jenkins_home jenkins
```

Como explicado anteriormente, o comando ```--detach``` libera o terminal, o ```-p``` associa uma porta do container a uma porta da máquina host. Já o ```jenkins``` no final diz qual imagem será usada, e o -v diz em qual diretório local será armazanado os dados da aplicação.

Depois de executar o comando acima, acessamos a url [http://jenkins.ivmelo.com](http://jenkins.ivmelo.com) para continuar a instalação do Jenkins e instalar os plugins necessários para fazer os builds do maven.

### Estratégia de atualização das aplicações.

#### Gitlab
Seguindo a documentação oficial do gitlab para docker, para atualizar uma instalação do gitlab feita por docker, basta trocar o container por um com a versão mais nova. Como todos os dados são armazenados em um diretório pré definido na máquina host, a troca do container não acarretará na perda dos dados.

Após trocar o container, a nova imagem do gitlab se encarregará de reconfigurar e se atualizar automaticamente.

Sendo assim, a atualização do gitlab se dá em uma série de 4 comandos simples:

1. Parar a execução do container.
```
sudo docker stop gitlab
```

2. Remover o container.
```
sudo docker rm gitlab
```

3. Baixar a versão mais recente do gitlab.
```
sudo docker pull gitlab/gitlab-ce:latest
```

4. Criar o container novamente, usando as opções previamente definidas.
```
sudo docker run --detach \
    --hostname gitlab.ivmelo.com \
    --publish 443:443 --publish 80:80 --publish 22:22 \
    --name gitlab \
    --restart always \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest
```

Como dito anteriormente, após isso, durante a primeira execução, o gitlab vai se reconfigurar e se atualizar automaticamente.

Um arquivo chamado ```update_gitlab.sh``` pode ser encontrado neste repositório.

#### Jenkins
