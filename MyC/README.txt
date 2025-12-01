    Ce projet consiste à développer un compilateur générant du PCode à partir d’un langage source nommé MyC. 
Le travail s’est construit progressivement, chaque étape ajoutant une fonctionnalité : expressions, 
typage, variables, contrôle, gestion de portée, puis fonctions simples, typées, imbriquées et enfin récursives.

//------------------------------------------------------------------------------------------------------\\

                Partie 1: Gestion des expressions arithmétiques entières avec constantes

\\------------------------------------------------------------------------------------------------------//

    La première étape concernait la compilation des expressions arithmétiques entières. Le compilateur reconnaît
les opérations +, -, * et / appliquées à des constantes, et génère les instructions LOADI(n) puis ADDI, SUBI,
MULTI ou DIVI. Le résultat d’une expression doit toujours se retrouver au sommet de la pile.



//-------------------------------------------------------------------------------------------------------\\

        Partie 2: Gestion des constantes flottantes, gestions des types INT et FLOAT avec conversion

\\-------------------------------------------------------------------------------------------------------//

    La deuxième étape a introduit les types INT et FLOAT. LOADF(f) permet de charger des valeurs flottantes, et 
les opérations arithmétiques correspondantes utilisent ADDF, SUBF, MULTF ou DIVF. Lorsqu’une expression mélange
des entiers et des flottants, une conversion automatique de INT vers FLOAT est générée via I2F1 ou I2F2. 
La conversion inverse est interdite et signalée comme erreur.




//-------------------------------------------------------------------------------------------------------\\

                            Partie 3: Gestion des variables globales

\\-------------------------------------------------------------------------------------------------------//

    Une fois les expressions typées stabilisées, la gestion des variables globales a été ajoutée. La déclaration, 
la lecture, l’écriture et le stockage mémoire sont pris en charge avec une table des symboles associant chaque 
variable à un offset croissant. Le PCode généré utilise ensuite des instructions de LOAD ou STORE basées sur 
cet emplacement. Tout cela était géré à l'intérieure de la fonction du pcode produit init_glob_var qui empile la 
valeur initiale de la variable comme zéro (LOADI(0)) et initialise la variable dans la table des symbole avec 
l'offset correspondant grâce à la structure de données attribute. 




//-------------------------------------------------------------------------------------------------------\\

                            Partie 4: Gestion des structures de contrôles

\\-------------------------------------------------------------------------------------------------------//

    Les structures de contrôle if, if-else et while ont ensuite été intégrées. Elles reposent sur la génération de 
labels uniques et sur l’évaluation correcte des expressions booléennes pour déterminer les sauts conditionnels.
Ceci est établie de façon qu'on ajoute le test après l'évaluation de la condition, on teste si l'évaluation est 
fausse et si c'est le cas on fait un saut de label à (false_n), avec n est le numéro de label stocké dans l'attribut 
if ou while et géré avec la fonction newLabel() fournie.




//-------------------------------------------------------------------------------------------------------\\

                            Partie 5: Gestion des booléens paresseux

\\-------------------------------------------------------------------------------------------------------//

    Une étape optionnelle a ensuite introduit l’évaluation paresseuse des expressions booléennes (&&, ||, !). 
La génération de code ne repose plus sur une simple valeur en pile, mais sur des branchements. 

    Cette fonctionnalité a pu être mise en place rapidement grâce à la découverte qu’il était possible d’insérer 
du code entre les éléments de la règle dans la grammaire Bison, ce qui a permis d’ajouter directement les sauts
vers les bons labels au moment où la logique devient déterminable (par exemple : true || x n’évalue jamais x).



//-------------------------------------------------------------------------------------------------------\\

                            Partie 6: Gestion des sous-blocs et des variables locales

\\-------------------------------------------------------------------------------------------------------//

    La gestion des sous-blocs et des variables locales est venue ensuite avec une table des symboles utilisée comme 
pile. Chaque entrée dans un bloc pousse un contexte, chaque sortie le supprime. Les variables locales sont 
associées à un offset relatif à un pointeur de bloc bp, ce qui rend possible une portée lexicale propre 
indépendante des offsets globaux, et permettant d'accéder à ces variables.



//-------------------------------------------------------------------------------------------------------\\

                Partie 7 et 8: Gestion des fonctions simples ou typées, non récursives et sans sous-blocs

\\-------------------------------------------------------------------------------------------------------//

    Les premières fonctions ajoutées étaient non typées, sans récursion et sans bloc interne. Une fonction 
int add(a, b){} devient une fonction PCode void pcode_add(){} où les arguments sont empilés avant appel et où la valeur
renvoyée reste au sommet de la pile. Les fonctions typées ont ensuite complété ce modèle : paramètres et valeur
de retour peuvent être INT, FLOAT ou VOID, avec conversions automatiques INT → FLOAT si nécessaire, et aucune
valeur laissée en pile dans le cas VOID.




//-------------------------------------------------------------------------------------------------------\\

                Partie 9: Gestion des fonctions non récursives avec sous-blocs

\\-------------------------------------------------------------------------------------------------------//

    Par la suite, les fonctions ont été étendues pour supporter des sous-blocs et donc des retours situés à 
l’intérieur de structures imbriquées, tout en maintenant correctement le contexte mémoire et la table des symboles. 
La dernière étape a permis l’ajout de la récursion, nécessitant une gestion fiable de la structure d’activation et 
la mise à jour correcte du pointeur de base pour chaque appel.



//-------------------------------------------------------------------------------------------------------\\

                        Partie 10: Gestion des fonctions récursives générales

\\-------------------------------------------------------------------------------------------------------//

    La dernière étape du projet a permis d’ajouter la prise en charge des fonctions récursives, c’est-à-dire la 
capacité pour une fonction de s’appeler elle-même, directement ou via d’autres fonctions. Pour cela, il a été
nécessaire d’adapter le modèle d’activation : chaque appel doit créer un nouvel environnement d'exécution 
contenant les paramètres, variables locales et informations de retour, sans écraser l'appel précédent.




//-------------------------------------------------------------------------------------------------------\\

                                    Utilisation et fonctionnement

\\-------------------------------------------------------------------------------------------------------//

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