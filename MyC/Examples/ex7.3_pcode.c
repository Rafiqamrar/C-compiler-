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

void pcode_plusUn() {
    LOADBP;
    SHIFT(-1);
    LOAD;
    LOADI(1);
    ADDI;
    LOADBP;
    SHIFT(-2);
    STORE; 
}

void pcode_main() {
    LOADI(0);
    // Appel de fonction plusUn
    // Type de retour: int
    // La fonction plusUn retourne une valeur
    LOADI(0);   // RÃ©server de l'espace pour la valeur de retour
    LOADI(1);
    SAVEBP;
    CALL(pcode_plusUn);
    RESTOREBP;
    DROP(1);   // Depilement arguments
    LOADBP; 
    SHIFT(1);
    STORE;
}

