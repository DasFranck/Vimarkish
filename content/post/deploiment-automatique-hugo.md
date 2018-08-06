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
  - "Vie du blog"
tags:
  - "hugo"
  - "webhooks"
  - "github"
  - "vimarkish"
---


---

Bon, le blog est en ligne et c'est bien beau mais c'est un peu lourd de devoir se connecter en ssh au serveur à chaque fois pour regénerer tout le contenu.  
Alors aujourd'hui on va automatiser tout ça.

<!--more-->

Mon blog Hugo est tourne sur un serveur Archlinux et son contenu est stocké sur [GitHub](https://github.com/DasFranck/Vimarkish).
Lorsque je push une modification sur son répertoire, il faudrait que mon serveur pull les modifications et lance une regénération du blog.

Pour celà, on va utiliser les [webhooks github](https://developer.github.com/webhooks/) et l'outil [webhook](https://github.com/adnan/webhook/).  
Oui, ça peut porter facilement à confusion et je sais pas comment le gars qui a pondu cet outil s'est dit que c'était une bonne idée.

Ce qui nous donne le cheminement suivant:

GitHub (ou tout autre forge logicielle suportant les webhooks) va donc se charger de lancer des requêtes POST sur l'adresse du serveur à chaque push.  

Webhook va lancer un petit serveur d'écoute HTTP afin de recevoir ces requêtes POST, les analyer et executer des tâches en fonction du contenu de ces derniers.

Hugo va compiler tout ce beau markdown en html.

Et derrière apache continue son 