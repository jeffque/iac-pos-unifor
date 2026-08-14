Para estudos de infraestrutura como código

Subindo AWS CLI via docker-compose (`docker compose run --rm -i aws`)

Para garantir tudo funcionando, rode o comando `./init.sh`. Ele vai criar eventual estrutura que não seja adequada commitar (como `~/.aws`). Como se está rodando sobre AWS CLI no docker, o container é efêmero.

# Para subir a infra

```bash
docker compose run -i --rm --entrypoint sh aws
```

Eventualmente, alterações no Dockerfile precisam ser buildadas novamente. Se for o caso:

```bash
docker compose build aws
```

Dentro do container:

```bash
terraform init
```

Isso vai iniciar o `terraform` e podemos começar o serviço:

```bash
terraform plan               # para verificar o plano
terraform plan -ou my-plan   # para salvar o plano que será aplicado
terraform apply              # aplica sem seguir um plano
terraform apply my-plan      # aplica o plano "my-plan"
```

Para pegar o .ini a partir do `terraform`:

```bash
terraform output -raw ansible_ini > inventory.ini
```

No ansbile, testar o ping:

```bash
ansible servidores_web -i inventory.ini -m ping
```

E também no ansible, aplicar o playbook:

```bash
ansible-playbook -i inventory.ini site.yml
```

Para matar:

```bash
terraform destroy
```


# Sequência do trabalho

Conectar na máquina (via SSH). Pode chegar nela na primeira vez via:

https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#Instances:instanceState=running

> Aqui o exemplo porque a região criada é us-east-1 !!!

Fazer o ansible para instalar o nginx. Colocar o `index.html`
