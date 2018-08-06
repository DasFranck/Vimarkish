---
title: "Déploiment automatique du blog sous Hugo avec les webhooks"
date: 2018-08-05T15:37:58Z
#Lastmod: {{ .Date }}
type: post
slug: deploiment-automatique-hugo-webhooks
description: 
draft: true
categories:
  - "CI/CD"
  - "Vimarkish"
tags:
  - "hugo"
  - "webhooks"
  - "github"
  - "vimarkish"
---


---

Le blog est en ligne et c'est bien beau mais c'est un peu lourd de devoir se connecter en ssh au serveur à chaque fois pour regénerer tout le contenu.  
Aujourd'hui, on va automatiser tout ça.

<!--more-->
## Du contexte

Mon blog Hugo est tourne sur un serveur Archlinux, servi par Apache et son contenu est stocké sur [GitHub](https://github.com/DasFranck/Vimarkish).
Lorsque je push une modification sur son répertoire, il faudrait que mon serveur pull les modifications et lance une regénération du blog.

Pour celà, on va utiliser les [webhooks github](https://developer.github.com/webhooks/) et l'outil [webhook](https://github.com/adnan/webhook/).  
Oui, ça peut porter facilement à confusion et je sais pas comment le gars qui a pondu cet outil s'est dit que c'était une bonne idée.

Ce qui nous donne le cheminement suivant:

- GitHub (ou tout autre forge logicielle suportant les webhooks) va donc se charger de lancer des requêtes POST sur l'adresse du serveur à chaque push.  
- Webhook va lancer un petit serveur d'écoute HTTP afin de recevoir ces requêtes POST, les analyer et executer des tâches en fonction du contenu de ces derniers.  
- Hugo va compiler tout ce beau markdown en html.
- Apache continue son taf habituel et servira les pages.

## GitHub
Blabla ici

## Webhook
### Installation
- ArchLinux: Installez le depuis [AUR](https://aur.archlinux.org/packages/webhook/)
- Ubuntu (17.04 ou plus) ou Debian (stretch): ```sudo apt-get install webhook```
- [Le reste des distributions linux](https://github.com/adnanh/webhook/#installation)

### Configuration
Niveau configuration j'ai ceci:
```yaml
[
  {
    "id": "vimarkish",
    "execute-command": "/srv/http/Vimarkish/deploy.sh",
    "command-working-directory": "/srv/http/Vimarkish",
    "trigger-rule":
    {
      "and":
      [
        {
          "match":
          {
            "type": "payload-hash-sha1",
            "secret": "mysecret",
            "parameter":
            {
              "source": "header",
              "name": "X-Hub-Signature"
            }
          }
        },
        {
          "match":
          {
            "type": "value",
            "value": "refs/heads/master",
            "parameter":
            {
              "source": "payload",
              "name": "ref"
            }
          }
        }
      ]
    }
  }
]
```

En gros si le secret correspond à celui dans le fichier et que le push a été effectué sur la branche master, il lance le script deploy.sh.

```sh
#!/bin/sh

git pull
hugo --quiet
chown -R www:www /srv/http/Vimarkish/
```

Le script est simple mais efficace.

### Daemonization
Si quelqu'un a un terme moins hideux, je suis preneur.  

Cette étape consiste simplement à créer une unité pour systemd, dans mon cas je l'ai placé à `/etc/systemd/system/vimarkish_webhook`

```ini
[Unit]
Description=Webhook server for Vimarkish

[Service]
ExecStart=/usr/bin/webhook -hooks /home/dasfranck/vimarkish_webhooks.json

[Install]
WantedBy=default.target
```

On oublie pas de recharger les daemons avant d'essayer de l'activer et de le lancer:
```
sudo systemctl daemon-reload
sudo systemctl start vimarkish_webhook.service
sudo systemctl enable vimarkish_webhook.service
```