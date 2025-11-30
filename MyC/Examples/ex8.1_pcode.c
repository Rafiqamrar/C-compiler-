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

void pcode_min() {
    LOADBP;
    SHIFT(-2);
    LOAD;
    LOADBP;
    SHIFT(-1);
    LOAD;
    LTI;
    IFN(False_0);
    SAVEBP;
    LOADBP;
    LOAD; // accessing upper block depth 2
    SHIFT(-2);
    LOAD;
    LOADBP;
    LOAD; // accessing upper block depth 2
    SHIFT(-3);
    STORE; 
    RESTOREBP;
    // la condition 0 est vraie
    GOTO(End_0);
False_0:
    // la condition 0 est fausse
    SAVEBP;
    LOADBP;
    LOAD; // accessing upper block depth 2
    SHIFT(-1);
    LOAD;
    LOADBP;
    LOAD; // accessing upper block depth 2
    SHIFT(-3);
    STORE; 
    RESTOREBP;
End_0:
//fin de conditionnelle
}

void pcode_main() {
    LOADF(0.0);
    // Appel de fonction min
    // Type de retour: int
    // La fonction min retourne une valeur
    LOADI(0);   // RÃ©server de l'espace pour la valeur de retour
    LOADI(1);
    LOADI(2);
    SAVEBP;
    CALL(pcode_min);
    RESTOREBP;
    DROP(2);   // Depilement arguments
    I2F2;
    LOADBP; 
    SHIFT(1);
    STORE;
}

