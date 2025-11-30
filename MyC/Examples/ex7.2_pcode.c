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

void pcode_one() {
    LOADI(1);
    LOADBP;
    SHIFT(-1);
    STORE; 
}

void pcode_main() {
    LOADI(0);
    // Appel de fonction one
    // Type de retour: int
    // La fonction one retourne une valeur
    LOADI(0);   // RÃ©server de l'espace pour la valeur de retour
    SAVEBP;
    CALL(pcode_one);
    RESTOREBP;
    LOADBP; 
    SHIFT(1);
    STORE;
}

