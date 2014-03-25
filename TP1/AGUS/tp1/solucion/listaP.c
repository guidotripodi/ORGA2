#include <stdlib.h>
#include <string.h>

#include "listaP.h"

listaP *lista_crear() {
    listaP *ls = malloc(sizeof *ls);

    ls->prim = NULL;
    ls->ult = NULL;
    return ls;
}

void lista_agregar(listaP *ls, const char *palabra) {
    int len = strlen(palabra);
    char *new = malloc(sizeof *new * len + 1);
    strncpy(new, palabra, len + 1);

    lsnodo *n = malloc(sizeof *n);
    n->valor = new;
    n->sig = NULL;

    if (ls->prim == NULL) {
        ls->prim = n;
        ls->ult = n;
    } else {
        ls->ult->sig = n;
        ls->ult = n;
    }
}

void lista_borrar(listaP *ls) {
    lsnodo *n = ls->prim;

    while (n != NULL) {
        free(n->valor);
        lsnodo *oldn = n;
        n = n->sig;
        free(oldn);
    }
    free(ls);
}

void lista_concatenar(listaP *xs, listaP *ys) {
    if (xs->prim == NULL) {
        xs->prim = ys->prim;
    } else {
        xs->ult->sig = ys->prim;
    }
    xs->ult = ys->ult;
    free(ys);
}
