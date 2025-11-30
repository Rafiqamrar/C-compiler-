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

void pcode_plus() {
    LOADBP;
    SHIFT(-2);
    LOAD;
    LOADBP;
    SHIFT(-1);
    LOAD;
    ADDI;
    LOADBP;
    SHIFT(-3);
    STORE; 
}

void pcode_main() {
    LOADI(0);
    // Appel de fonction plus
    // Type de retour: int
    // La fonction plus retourne une valeur
    LOADI(0);   // RÃ©server de l'espace pour la valeur de retour
    LOADI(1);
    LOADI(2);
    SAVEBP;
    CALL(pcode_plus);
    RESTOREBP;
    DROP(2);   // Depilement arguments
    LOADBP; 
    SHIFT(1);
    STORE;
}

