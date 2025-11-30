// PCode Header
   	#include "PCode.h"
   	
   	void pcode_main();
   	void init_glob_var();
   	
   	int main() {
   	init_glob_var();
   	pcode_main();
   	return stack[sp-1].int_value;
   	}
   	

void init_glob_var(){
}

void pcode_fact() {
    LOADBP;
    SHIFT(-1);
    LOAD;
    LOADI(1);
    LTI;
    IFN(False_0);
    LOADI(1);
    LOADBP;
    SHIFT(-2);
    STORE; 
    // la condition 0 est vraie
    GOTO(End_0);
False_0:
    // la condition 0 est fausse
End_0:
//fin de conditionnelle
    LOADBP;
    SHIFT(-1);
    LOAD;
    // Appel de fonction fact
    // Type de retour: int
    // La fonction fact retourne une valeur
    LOADI(0);   // RÃ©server de l'espace pour la valeur de retour
    LOADBP;
    SHIFT(-1);
    LOAD;
    LOADI(1);
    SUBI;
    SAVEBP;
    CALL(pcode_fact);
    RESTOREBP;
    DROP(1);   // Depilement arguments
    MULTI;
    LOADBP;
    SHIFT(-2);
    STORE; 
}

void pcode_main() {
    // Appel de fonction fact
    // Type de retour: int
    // La fonction fact retourne une valeur
    LOADI(0);   // RÃ©server de l'espace pour la valeur de retour
    LOADI(5);
    SAVEBP;
    CALL(pcode_fact);
    RESTOREBP;
    DROP(1);   // Depilement arguments
}

