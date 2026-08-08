Para estudos de infraestrutura como código

Subindo AWS CLI via docker-compose (`docker compose run --rm -i aws`)

Para garantir tudo funcionando, rode o comando `./init.sh`. Ele vai criar eventual estrutura que não seja adequada commitar (como `~/.aws`). Como se está rodando sobre AWS CLI no docker, o container é efêmero.