---
title: "Optimiser un site web statique généré par Hugo"
date: 2018-08-10T11:55:00Z
#Lastmod: {{ .Date }}
draft: true
type: post
slug: optimisation-site-statique
description: 
categories:
  - "Adminstration Système"
  - "Vimarkish"
tags:
  - "Vimarkish"
  - "Hugo"
  - "Apache"
  - "Gzip"
---

Selon quelques tests, ce blog est un peu lourd à chager car mal optimisé.  
On va aussi s'occuper de ça.

<!--more-->

# Du contexte

Tout d'abord, qu'est ce qui ne va pas sur ce site statique (et peut-être le votre) ?
Selon [Google PageSpeed](https://developers.google.com/speed/), je devrais minifier mes ressources et les compresser avant de les servir. Et pour les ressources qui changent rarement, les mettre en plus en cache pour pas que l'utilisateur ait à tout retélécharger à chaque fois.  
Même constat avec [GTMetrix](https://gtmetrix.com) et [PingDom](https://tools.pingdom.com).

Qu'est ce que [minifier](https://en.wikipedia.org/wiki/Minification_(programming)) ?  
Il s'agit de réduire la taille du code en dégageant tout le superflu pour une machine, c'est à dire tout ce qui est commentaires, noms de variable explicites, espaces et sauts de ligne non-nécessaires à la syntaxe dans les fichiers CSS/JS.  
Un exemple ?
```js
var array = [];
for (var i = 0; i < 20; i++) {
  array[i] = i;
}
```
```js
for(var a=[i=0];++i<20;a[i]=i);
```
Les deux codes seront strictement identiques pour l'interpréteur javascript. Mais le poids du fichier passe de 65 octect à 32 octect soit une diminution de 51%.

Voici le résultat GTMetrix pour ce site statique pour les fichiers JavaScript et CSS:  
![Résultats GTMetrix JavaScript](/images/optimisation-site-statique/GTMetrix-javascript.png)  
![Résultats GTMetrix CSS](/images/optimisation-site-statique/GTMetrix-css.png)


Résumons donc, il faut:
- Minifier les fichiers CSS
- Minifier les fichiers Javascript
- Minifier les fichiers HTML, même si relativement peu utile
- Compresser tout ça à la volée quand Apache sert mes pages et ressources