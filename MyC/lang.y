%{


#include "Table_des_symboles.h"

#include <stdio.h>
#include <stdlib.h>
#include "PCode/PCode.h"
  
extern int yylex();
extern int yyparse();

void yyerror (char* s) {
  printf ("%s\n",s);
  exit(0);
  }
		
int depth=0; // block depth
int offset=0; // variable offset in current block
int param_offset=-1; // parameter offset in current function
int current_decl_type; // type of current declaration (used in vlist)
 
int label_counter = 0;

int newLabel() {

    return label_counter++;
}


void reset_offset() {
    offset = 0;
    param_offset = -1;

}

void enter_block() {
    if (depth > 1) {  // Functions and sub-blocks
        printf("    SAVEBP;\n");
    }
    depth++;
    reset_offset();
}
void exit_block() {
    depth--;
    //printf("    // DEBUG: exit_block() - new_depth=%d\n", depth);
    if (depth > 1) {
        printf("    RESTOREBP;\n");
    }
}


void generate_variable_address(attribute a) {
    if (a == NULL) {
        printf("    // ERREUR: Variable non trouvée\n");
        return;
    }

    printf("    // generate_variable_address: depth=%d, offset=%d\n", a->depth, a->offset);

    
    if (a->depth == depth) {
        if (a->offset >= 0) {
            // Variable locale
            printf("    LOADBP; \n");
            printf("    SHIFT(%d);\n", a->offset + 1);
        } else {
            // Paramètre (offset négatif)
            printf("    LOADBP; \n");
            printf("    SHIFT(%d);\n", a->offset); 
        }
    } else if (a->depth == 0) {
        // Variable globale
        printf("    LOADI(%d);\n" , a->offset);

        //printf("   SHIFT(%d); \n", a->offset);
        
        
    } else {
        // Variable parente
        printf("    LOADBP;\n");
        if (depth - a->depth > 1) {
            // Monter dans les blocs parents
            for (int i = 0; i < depth - a->depth - 1; i++) {
        printf("    LOAD; accessing upper block depth %d\n" , a->depth);            }
        }

          if (a->offset >= 0) {
            //printf("    LOAD;\n ");
            // Variable locale du parent
            printf("    SHIFT(%d);\n", a->offset + 1);
        } else {
            // Paramètre du parent  
            printf("    SHIFT(%d);\n", a->offset);
        }
    }
}




// Variables globales ajoutées
char *current_function_name = NULL;
int current_function_param_count = 0;

void start_function(char *name) {
    current_function_name = name;
    current_function_param_count = 0;
}

void add_parameter() {
    current_function_param_count++;
    printf("// DEBUG: add_parameter - count now=%d\n", current_function_param_count);
}

void end_function() {
    current_function_name = NULL;
    current_function_param_count = 0;
}

void register_function(char *name, int return_type, int param_count) {
    // Utiliser offset = -1 pour identifier les fonctions
    // depth = 0 pour les fonctions globales
    attribute func_attr = makeSymbol(return_type, -param_count, 0);
    set_symbol_value(name, func_attr);
    //debug
 printf("// DEBUG: Registered function %s with %d params (offset=%d)\n", 
           name, param_count, -param_count);
}

// Vérifier si un symbole est une fonction
int is_function(attribute a) {
    return (a != NULL && a->offset == -1 && a->depth == 0);
}




%}

%union { 
  struct ATTRIBUTE * symbol_value;
  char * string_value;
  int int_value;
  float float_value;
  int type_value;
  int label_value;
  int offset_value;
}

%token <int_value> NUM
%token <float_value> DEC


%token INT FLOAT VOID

%token <string_value> ID
%token AO AF PO PF PV VIR
%token RETURN  EQ
%token <label_value> IF ELSE WHILE

%token <label_value> AND OR NOT DIFF EQUAL SUP INF
%token PLUS MOINS STAR DIV
%token DOT ARR
//%token <string_value> FID

%nonassoc IFX
%left OR                       // higher priority on ||
%left AND                      // higher priority on &&
%left DIFF EQUAL SUP INF       // higher priority on comparison
%left PLUS MOINS               // higher priority on + - 
%left STAR DIV                 // higher priority on * /
%left DOT ARR                  // higher priority on . and -> 
%nonassoc UNA                  // highest priority on unary operator
%nonassoc ELSE


%{
char * type2string (int c) {
  switch (c)
    {
    case INT:
      return("int");
    case FLOAT:
      return("float");
    case VOID:
      return("void");
    default:
      return("type error");
    }  
};

 // dirty trick to end function init_glob_var() definition (see rule po : PO)
void end_glob_var_decl(){
  static int unfinished=1;
  if (unfinished) {
    unfinished = 0; 
    printf("}\n\n");
  }
}

// Votre code C peut aller ci-dessous pour factoriser (un peu) le code des actions semantiques
 
  %}


%start prog  

// liste de tous les type des attributs des non terminaux que vous voulez manipuler l'attribut (il faudra en ajouter plein ;-) )
%type <type_value> type exp  typename
%type <string_value> fun_head
%type <type_value> aff
%type <label_value> cond if else bool_cond loop while elsop
%type <type_value> app ret
%type <string_value> fid 
%type <int_value> params arglist 


%%

 // O. Déclaration globale

prog : glob_decl_list              {}
;

glob_decl_list : glob_var_list glob_fun_list {}
;

glob_var_list : glob_var_list decl PV {}
| {printf("void init_glob_var(){\n"); // starting  function init_glob_var() definition in target code
  reset_offset();  // reset offset for global variables
 }
;

glob_fun_list : glob_fun_list fun {}
| fun {}
;

// I. Functions

fun : type fun_head fun_body   {

}
;

po: PO {end_glob_var_decl();}  // dirty trick to end function init_glob_var() definition in target code
  
fun_head : ID po PF            {
  // Pas de déclaration de fonction à l'intérieur de fonctions !
  if (depth>0) yyerror("Function must be declared at top level~!\n");
  start_function($1);
  //reset offset for parameters
  param_offset = -1;


  }

| ID po params PF              {
   // Pas de déclaration de fonction à l'intérieur de fonctions !
  if (depth>0) yyerror("Function must be declared at top level~!\n");
  start_function($1);
  param_offset = -1;
  register_function($1, $<type_value>0, $3);


 }
;


params : type ID vir params
{
    // Paramètre: type 1, nom 2
    // Attribuer offset NÉGATIF
    int current_offset = param_offset;
    attribute a = makeSymbol($1, current_offset, 1); // depth=1, offset négatif
    set_symbol_value($2, a);
    printf("// DEBUG: Paramètre %s - offset=%d (avant offset--)\n", $2, current_offset);

    param_offset--;
    add_parameter();
    printf("// DEBUG: params - added param %s, count=%d\n", $2, current_function_param_count);
    $$ =current_function_param_count;


    
}
| type ID
{
    // Dernier paramètre
    attribute a = makeSymbol($1, param_offset, 1);
    set_symbol_value($2, a);
    printf("// DEBUG: Dernier paramètre %s - offset=%d (avant offset--)\n", $2, param_offset);
    param_offset--;
    add_parameter();
    printf("// DEBUG: params - added param %s, count=%d\n", $2, current_function_param_count);
    $$ =current_function_param_count;

}
;


vir : VIR                      {}
;

fun_body :{
   if (current_function_name == NULL) {
        yyerror("No current function name!");
    }

        printf("void pcode_%s() {\n", current_function_name);

        //register_function(current_function_name, $<type_value>0, current_function_param_count);
        printf("    // Fonction %s: type=%s, params=%d\n", 
               current_function_name, type2string($<type_value>0), current_function_param_count);
        
        enter_block(); 

}
 fao block faf       {
        exit_block();   // ← Détruit le contexte fonction

        printf("}\n\n");
        end_function();
 }
;

fao : AO                       {}
;
faf : AF                       {}
;


// II. Block

block:
    { 
        if (depth >= 1) { // Sous-blocs seulement (pas pour le bloc fonction)
            enter_block();
        }
    }
    decl_list inst_list 
    { 
        if (depth >= 1) { // Sous-blocs seulement
            exit_block();
        }
    }

// III. Declarations

decl_list : decl_list decl PV   {} 
|                               {}
;

decl: var_decl                  {}
;

var_decl :
      type  vlist
      {}
;


vlist :
      vlist VIR ID
{
    attribute a = makeSymbol($<type_value>0, offset, depth);
    set_symbol_value($3, a);
    //printf("    // DECL %s: depth=%d, offset=%d\n", $3, depth, offset); //DEBUG
    if (a->type == INT)
        printf("    LOADI(0);\n");
    else
        printf("    LOADF(0.0);\n");

    //printf("    LOADI(%d);\n", a->offset);
    //printf("    STORE;\n");
    

    offset++;
}
| ID
{
    attribute a = makeSymbol($<type_value>0, offset, depth);
    set_symbol_value($1, a);

    if (a->type == INT)
        printf("    LOADI(0);\n");
    else
        printf("    LOADF(0.0);\n");

    //printf("    LOADI(%d);\n", a->offset);
    //printf("    STORE;\n");

    offset++;
}
;










type
: typename                     {}
;

typename // Utilisation des terminaux comme codage (entier) du type !!!
: INT                          {$$=INT;} 
| FLOAT                        {$$=FLOAT;}
| VOID                         {$$=VOID;}
;

// IV. Intructions

inst_list: inst_list decl PV   {} 
|inst_list inst          {}
| inst                      {}
;

pv : PV                       {}
;
 
inst:
ao block af                   
| exp pv                      {}
| aff pv                      {}
| ret pv                      {}
| cond                        {}
| loop                        {}
| pv                          {}
;

// Accolades explicites pour gerer l'entrée et la sortie d'un sous-bloc

ao : AO                       {}
;

af : AF                       {}
;


// IV.1 Affectations
aff : ID EQ exp
{
    attribute a = get_symbol_value($1);
    if (a == NULL)
        yyerror("Variable non déclarée");

    int type_var = a->type;
    int type_exp = $3;

    // Conversion INT -> FLOAT si nécessaire
    if (type_var == FLOAT && type_exp == INT) {
        printf("    I2F2;\n");
    }

    // Erreur si FLOAT → INT
    if (type_var == INT && type_exp == FLOAT) {
        yyerror("Assignation float vers int interdite");
    }


    // Charger l'adresse de la variable
    //printf("    LOADI(%d);\n", a->offset);
    generate_variable_address(a);
    // STORE : stocke la valeur dans la variable
    printf("    STORE;\n");

    $$ = type_var;   

}






// IV.2 Return
ret : RETURN exp
{
    if (current_function_name == NULL) {
        yyerror("Return outside function!");
    }
    
    // Récupérer le type de la fonction depuis la table
    attribute func_attr = get_symbol_value(current_function_name);
    if (func_attr == NULL) {
        yyerror("Current function not found");
    }
    
    int function_type = func_attr->type;
    int expr_type = $2;
    
    //check_return_compatibility(function_type, expr_type);
    //check type compatibility
    if (function_type == INT && expr_type == FLOAT) {
        yyerror("Cannot return float from int function");
    }
    if (function_type == VOID) {
        yyerror("Void function cannot return a value");
    }
    if (function_type == INT && expr_type == FLOAT) {
          printf("    I2F2;\n");
    }
    // Conversion si nécessaire
    if (function_type == FLOAT && expr_type == INT) {
        printf("      I2F2;\n");
    }
    
    int param_count = -func_attr->offset;
    int return_offset = -(param_count + 1);

    attribute a = makeSymbol(function_type, return_offset, 1); //depth 1 pour fonction
    generate_variable_address(a);
    
    //printf("    LOADBP;\n");
    //printf("    SHIFT(%d);\n", return_offset);
    printf("    STORE; \n");

    
    $$ = function_type;
}
| RETURN PO PF
{
    if (current_function_name == NULL) {
        yyerror("Return outside function!");
    }
    
    attribute func_attr = get_symbol_value(current_function_name);
    if (func_attr && func_attr->type != VOID) {
        yyerror("Non-void function should return a value");
    }
    

    
    $$ = VOID;
}
;

// IV.3. Conditionelles
//           N.B. ces rêgles génèrent un conflit déclage reduction
//           qui est résolu comme on le souhaite par un décalage (shift)
//           avec ELSE en entrée (voir y.output)

cond :
    if {
      $1 = newLabel();
    }
    bool_cond {
      printf("    IFN(Lfalse_%d);\n", $1);
    }
    inst
    {
      printf("    GOTO(Lend_%d);\n", $1);
      printf("Lfalse_%d:\n", $1);
    } 
    elsop
    {
      printf("Lend_%d:\n", $1);
    }
;




elsop :
    else inst
{
}
| %prec IFX
{
  
  
}
;




bool_cond :
    PO exp PF                 {}
;






if : IF                       {}
;

else : ELSE                   {
}
;

// IV.4. Iterations

loop:
{
    printf("Loop_%d:\n", newLabel());
}
    while 
    {
      $2 = newLabel() - 1;
    }
    while_cond
    {
      printf("    IFN(EndLoop_%d);\n", $2);
    }
    inst
{
    printf("    GOTO(Loop_%d);\n", $2);   // retour au début
    printf("EndLoop_%d:\n", $2);
}
;

while_cond : PO exp PF        {}
;

while : WHILE                 {}
;

// V. Expressions

exp
: NUM
  {
    printf("    LOADI(%d);\n", $1);
    $$ = INT;
  }
| DEC
  {
    printf("    LOADF(%f);\n", $1);
    $$ = FLOAT;
  }
| MOINS exp %prec UNA
  {
        if ($2 == FLOAT) {
        printf("    MINUSF;\n");
        $$ = FLOAT;
        } else {
        printf("    MINUSI;\n");
        $$ = INT;
        }
  }
| exp PLUS exp
  {
    if ($1 == INT && $3 == INT) {
      printf("    ADDI;\n");
      $$ = INT;
    } else {
      // promotion vers float
      if ($1 == INT) printf("    I2F1;\n");
      if ($3 == INT) printf("    I2F2;\n");
      printf("    ADDF;\n");
      $$ = FLOAT;
    }
  }
| exp MOINS exp
  {
    if ($1 == INT && $3 == INT) {
      printf("    SUBI;\n");
      $$ = INT;
    } else {
      if ($1 == INT) printf("    I2F1;\n");
      if ($3 == INT) printf("    I2F2;\n");
      printf("    SUBF;\n");
      $$ = FLOAT;
    }
  }
| exp STAR exp
  {
    if ($1 == INT && $3 == INT) {
      printf("    MULTI;\n");
      $$ = INT;
    } else {
      if ($1 == INT) printf("    I2F1;\n");
      if ($3 == INT) printf("    I2F2;\n");
      printf("    MULTF;\n");
      $$ = FLOAT;
    }
  }
| exp DIV exp
  {
    if ($1 == INT && $3 == INT) {
      printf("    DIVI;\n");
      $$ = INT;
    } else {
      if ($1 == INT) printf("    I2F1;\n");
      if ($3 == INT) printf("    I2F2;\n");
      printf("    DIVF;\n");
      $$ = FLOAT;
    }
  }
| PO exp PF
  {
    $$ = $2;
  }

| ID
{
    attribute a = get_symbol_value($1);
    if (a == NULL) {
        yyerror("Variable non declaree");
    }

    // Charger la valeur gauche
    //printf("    LOADI(%d);\n", a->offset);
    generate_variable_address(a);
    // Charger la valeur droite
    printf("    LOAD;\n");

    $$ = a->type;
}
| app  // permettre les appels de fonction comme expressions
  {
    $$ = $1;  // Reprend le type déterminé dans la règle app
  }
;





// V.2. Booléens

| exp INF exp
  {
    //float vs int 
    if ($1 == FLOAT && $3 == INT) {
        printf("    I2F2;\n");
    } else if ($1 == INT && $3 == FLOAT) {
        printf("    I2F1;\n");
    }
    if ($1 == INT && $3 == INT) {    
      printf("    LTI;\n");   // < sur int (ou float casté dans PCode)
      $$ = INT;

}   else {
      printf("    LTF;\n");   // < sur int (ou float casté dans PCode)

}
    $$ = INT;
  }
| exp SUP exp
  {
if ($1 == FLOAT && $3 == INT) {
        printf("    I2F2;\n");
    } else if ($1 == INT && $3 == FLOAT) {
        printf("    I2F1;\n");
    }
    if ($1 == INT && $3 == INT) {    
      printf("    GTI;\n");   // < sur int (ou float casté dans PCode)
      $$ = INT;

}  else {
      printf("    GTF;\n");   // < sur int (ou float casté dans PCode) ;
}
    $$ = INT;
  }
| exp EQUAL exp
  {
if ($1 == FLOAT && $3 == INT) {
        printf("    I2F2;\n");
    } else if ($1 == INT && $3 == FLOAT) {
        printf("    I2F1;\n");
    }
    if ($1 == INT && $3 == INT) {    
      printf("    EQI;\n");   // < sur int (ou float casté dans PCode)
      $$ = INT;

}else { 
    printf("    EQF;\n");   // < sur int (ou float casté dans PCode)
}
    $$ = INT;
  }
| exp DIFF exp
  {
if ($1 == FLOAT && $3 == INT) {
        printf("    I2F2;\n");
    } else if ($1 == INT && $3 == FLOAT) {
        printf("    I2F1;\n");
    }
    if ($1 == FLOAT && $3 == INT) {    
      printf("    NEQI;\n");   // < sur int (ou float casté dans PCode)
      $$ = INT;

}
    printf("    NEQF;\n");   // < sur int (ou float casté dans PCode)
    $$ = INT;
  }
| NOT exp %prec UNA
  {
    // printf("    NOT;\n");
    // $$ = INT;
    yyerror("NOT/AND/OR non implementés (option booléens paresseux)");
  }
| exp AND exp
  {
   int L1 = newLabel();
   //compile $1 si vrai fais le suivant sinon saute a L1

    

  }
| exp OR exp
  {
    //yyerror("OR non implementé en version non paresseuse");
  }


;
// V.3 Applications de fonctions


app : fid PO {printf("    LOADI(0);\n");}  args PF
{
    attribute func_attr = get_symbol_value($1);
    if (func_attr == NULL) {
        yyerror("Function not declared");
    }
    
    int return_type = func_attr->type;
    int param_count = -func_attr->offset;
    
  
    
    // Les arguments sont déjà empilés par 'args'
    
    printf("    SAVEBP;\n");
    printf("    CALL(pcode_%s);\n", $1);
    printf("    RESTOREBP;\n");
    
    // Dépiler les arguments
    //printf("    //les nombres d'arguments: %d\n", param_count); // debug
   printf("    DROP(%d);   // Depilement arguments\n", param_count);
        
    // Si fonction void, rien n'est empilé, sinon la valeur de retour est au sommet
    $$ = return_type;
}
;

fid : ID                      {$$ = $1;}

args :  arglist               {
}
|                             {}
;

arglist : arglist VIR exp {
    // Conversion automatique INT → FLOAT si nécessaire
    if ($3 == INT) {
        // On pourrait convertir vers float si le paramètre attend float
        // Pour l'instant, on accepte tous les int
    } else if ($3 == FLOAT) {
        // On accepte les float
    }
  
}
| exp {
    if ($1 == INT) {
        // Accepté
    } else if ($1 == FLOAT) {
        // Accepté  
    }
}





%% 
int main () {

  /* Ici on peut ouvrir le fichier source, avec les messages 
     d'erreur usuel si besoin, et rediriger l'entrée standard 
     sur ce fichier pour lancer dessus la compilation.
   */

char * header =
"// PCode Header\n"
"#include \"PCode/PCode.h\"\n"
"#include <stdio.h>\n"
"\n"
"void pcode_main();\n"
"void init_glob_var();\n"
"\n"
"int main() {\n"
"    printf(\"=== DEBUT EXECUTION ===\\n\");\n"
"    init_glob_var();\n"
"    pcode_main();\n"
"    \n"
"    // Affichage debug\n"
"    printf(\"Stack pointer: %d\\n\", sp);\n"
"    printf(\"Contenu de la pile:\\n\");\n"
"    for (int i = 0; i < sp; i++) {\n"
"        printf(\"  stack[%d] = %d\\n\", i, stack[i].int_value);\n"
"    }\n"
"    \n"
"    printf(\"Variables globales: x=%d, y=%d, z=%d\\n\", \n"
"           stack[0].int_value, stack[1].int_value, stack[2].int_value);\n"
"    \n"
"    int result = stack[sp-1].int_value;\n"
"    printf(\"Valeur de retour: %d\\n\", result);\n"
"    printf(\"=== FIN EXECUTION ===\\n\");\n"
"    \n"
"    return result;\n"
"}\n"
"\n"; 

printf("%s\n",header); // ouput header
  
return yyparse (); // output your compilation
 
 
} 

