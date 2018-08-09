---
title: "Déploiement automatique du blog sous Hugo avec les webhooks"
date: 2018-08-08T12:00:00Z
#Lastmod: {{ .Date }}
type: post
slug: deploiement-automatique-hugo-webhooks
description: 
draft: true
categories:
  - "CI/CD"
  - "Vimarkish"
tags:
  - "Hugo"
  - "Webhooks"
  - "Github"
  - "Vimarkish"
---


---

Le blog est en ligne et c'est bien beau mais c'est un peu lourd de devoir se connecter en ssh au serveur à chaque fois pour re-générer tout le contenu.  
Aujourd'hui, on va automatiser tout ça.

<!--more-->
# Du contexte

Mon blog Hugo tourne sur un serveur Archlinux, est servi par Apache et son contenu est stocké sur [GitHub](https://github.com/DasFranck/Vimarkish).
Lorsque je push une modification sur son répertoire, il faudrait que mon serveur pull les modifications et lance une re-génération du blog.

Pour cela, on va utiliser les [webhooks github](https://developer.github.com/webhooks/) et l'outil [webhook](https://github.com/adnan/webhook/).  
Oui, ça peut porter facilement à confusion et je sais pas comment le gars qui a pondu cet outil s'est dit que c'était une bonne idée.

Ce qui nous donne le cheminement suivant:

- GitHub (ou tout autre forge logicielle supportant les webhooks) va donc se charger de lancer des requêtes POST sur l'adresse du serveur à chaque push.  
- Webhook va lancer un petit serveur d'écoute HTTP afin de recevoir ces requêtes POST, les analyser et executer des tâches en fonction du contenu de ces derniers.  
- Hugo va compiler tout ce beau markdown en html.
- Apache continue son taf habituel et servira les pages.  


# GitHub
Pour configurer github c'est assez simple, il suffit d'aller dans les paramètres et de sélectionner webhooks et de cliquer sur "Add Webhooks".  
![github-2](/images/deploiement-automatique-hugo/github-2.png)  

- Payload URL: `http://IP_DU_SERVEUR:PORT/hooks/ID_DU_WEBHOOK`
- Content Type: Qu'importe.
- Secret: Le secret envoyé par le webhook
- Events: On a besoin que de l'évènement push.

Pour les autres forges, le fonctionnement est assez similaire et dans le pire des cas leur documentation doit avoir une rubrique dédié aux webhooks.

# Webhook
## Installation
- ArchLinux: Installez le depuis [AUR](https://aur.archlinux.org/packages/webhook/)
- Ubuntu (17.04 ou plus) ou Debian (stretch): ```sudo apt-get install webhook```
- [Le reste des distributions linux](https://github.com/adnanh/webhook/#installation)

## Configuration
Niveau configuration j'ai ceci:
```json
[
  {
    "id": "vimarkish",
    "execute-command": "/usr/bin/sudo",
    "command-working-directory": "/srv/http/Vimarkish",
    "pass-arguments-to-command":
    [
      { 
        "source": "string",
        "name": "-uhttp"
      },
      {
        "source": "string",
        "name": "/srv/http/Vimarkish/deploy.sh"
      } 
    ]
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

En gros si le secret envoyé par le webhook correspond à celui présent ici et que le push a été effectué sur la branche master, il lance le script `deploy.sh` en tant que `http`.

`http` étant l'utilisateur par lequel apache accède au repository, il est important que ce soit lui qui crée et modifie les fichier pour ne pas avoir de problème de permissions.  
Pour ubuntu et debian, ce sera généralement www.

```sh
#!/bin/sh

git pull
hugo
```

Le script est simple mais efficace.

## Daemonization
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