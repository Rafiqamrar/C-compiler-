    Ce projet consiste à développer un compilateur générant du PCode à partir d’un langage source nommé MyC. 
Le travail s’est construit progressivement, chaque étape ajoutant une fonctionnalité : expressions, 
typage, variables, contrôle, gestion de portée, puis fonctions simples, typées, imbriquées et enfin récursives.

    La première étape concernait la compilation des expressions arithmétiques entières. Le compilateur reconnaît
les opérations +, -, * et / appliquées à des constantes, et génère les instructions LOADI(n) puis ADDI, SUBI,
MULTI ou DIVI. Le résultat d’une expression doit toujours se retrouver au sommet de la pile.

    La deuxième étape a introduit les types INT et FLOAT. LOADF(f) permet de charger des valeurs flottantes, et 
les opérations arithmétiques correspondantes utilisent ADDF, SUBF, MULTF ou DIVF. Lorsqu’une expression mélange
des entiers et des flottants, une conversion automatique de INT vers FLOAT est générée via I2F1 ou I2F2. 
La conversion inverse est interdite et signalée comme erreur.

    Une fois les expressions typées stabilisées, la gestion des variables globales a été ajoutée. La déclaration, 
la lecture, l’écriture et le stockage mémoire sont pris en charge avec une table des symboles associant chaque 
variable à un offset croissant. Le PCode généré utilise ensuite des instructions de LOAD ou STORE basées sur 
cet emplacement.

    Les structures de contrôle if, if-else et while ont ensuite été intégrées. Elles reposent sur la génération de 
labels uniques et sur l’évaluation correcte des expressions booléennes pour déterminer les sauts conditionnels.

    Une étape optionnelle a ensuite introduit l’évaluation paresseuse des expressions booléennes (&&, ||, !). 
La génération de code ne repose plus sur une simple valeur en pile, mais sur des branchements. 
Cette fonctionnalité a pu être mise en place rapidement grâce à la découverte qu’il était possible d’insérer 
du code entre les éléments de la règle dans la grammaire Bison, ce qui a permis d’ajouter directement les sauts
vers les bons labels au moment où la logique devient déterminable (par exemple : true || x n’évalue jamais x).

    La gestion des sous-blocs et des variables locales est venue ensuite avec une table des symboles utilisée comme 
pile. Chaque entrée dans un bloc pousse un contexte, chaque sortie le supprime. Les variables locales sont 
associées à un offset relatif à un pointeur de bloc bp, ce qui rend possible une portée lexicale propre, 
indépendante des offsets globaux.

    Les premières fonctions ajoutées étaient non typées, sans récursion et sans bloc interne. Une fonction 
int add(a, b){} devient une fonction PCode pcode_add() où les arguments sont empilés avant appel et où la valeur
renvoyée reste au sommet de la pile. Les fonctions typées ont ensuite complété ce modèle : paramètres et valeur
de retour peuvent être INT, FLOAT ou VOID, avec conversions automatiques INT → FLOAT si nécessaire, et aucune
valeur laissée en pile dans le cas VOID.

    Par la suite, les fonctions ont été étendues pour supporter des sous-blocs et donc des retours situés à 
l’intérieur de structures imbriquées, tout en maintenant correctement le contexte mémoire et la table des symboles. 
La dernière étape a permis l’ajout de la récursion, nécessitant une gestion fiable de la structure d’activation et 
la mise à jour correcte du pointeur de base pour chaque appel.


    A partir du code décrit esentiellement dans le .y, ./Makefile produit
un executable ./lang qui compile stdin vers stdout. Une façon simple
de compiler un fichier source vers un fichier cible consiste alors à
rediriger les entrées et sorties.


    Le script bash runComp fait celà. Pour compiler un code source
ex.myc
en un code cible
ex_pcode.c
il suffit de lancer
runComp ex