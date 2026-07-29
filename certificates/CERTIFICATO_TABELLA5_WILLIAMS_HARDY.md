# Certificato indipendente contro Williams--Hardy, Tabella 5

**Data:** 29 luglio 2026

**Status:** VERIFICA COMPUTAZIONALE RIPRODUCIBILE, 22/22

**Script:** `verifica_tabella5_williams_hardy.py`

## Fonte primaria

K. S. Williams e K. Hardy, *A congruence for the index of a unit of a
real abelian number field*, Acta Arith. 46 (1985), 57--72, Teorema 5,
equazione (6.5), Tabella 5.

Il Teorema 5 considera un primo \(p=5f+1\), una radice primitiva \(g\)
modulo \(p\), sceglie

\[
\sqrt5=g^f-g^{2f}-g^{3f}+g^{4f}\pmod p
\]

e dimostra, per l'unità aurea

\[
\varepsilon=\frac{1+\sqrt5}{2},
\]

la congruenza

\[
\operatorname{ind}_5(\varepsilon)\equiv-u+3v\pmod5.
\]

La Tabella 5 pubblica 22 righe, per tutti i primi \(p\equiv1\pmod5\)
minori di 500.

## Protocollo del replay

Per ciascuna delle 22 righe il verificatore:

1. controlla che il valore pubblicato \(g\) sia una radice primitiva
   modulo \(p\);
2. ricostruisce \(\zeta=g^{(p-1)/5}\);
3. ricostruisce la stessa scelta di \(\sqrt5\) usata da
   Williams--Hardy e controlla \((\sqrt5)^2=5\);
4. calcola direttamente l'indice quintico di
   \(\varepsilon=(1+\sqrt5)/2\);
5. controlla la formula pubblicata
   \(\operatorname{ind}_5(\varepsilon)=-u+3v\);
6. costruisce direttamente
   \[
   U_2=(\zeta-1)(\zeta^2-1)^4(\zeta^3-1)^4(\zeta^4-1);
   \]
7. controlla l'identità
   \[
   U_2=(\sqrt5)^5\varepsilon^3;
   \]
8. calcola \(M_2=\operatorname{ind}_5(U_2)\) sia dal prodotto sia dalla
   somma pesata dei quattro indici;
9. controlla infine
   \[
   M_2=3\,\operatorname{ind}_5(\varepsilon)\pmod5.
   \]

Il verificatore usa soltanto la libreria standard di Python.

## Esito

```text
Williams--Hardy Table 5 vs golden moment
p    ind5(epsilon)    M2 direct    3*ind5(epsilon)
----------------------------------------------------------
 11         3              4               4
 31         4              2               2
 41         4              2               2
 61         2              1               1
 71         2              1               1
101         4              2               2
131         4              2               2
151         3              4               4
181         1              3               3
191         3              4               4
211         0              0               0
241         3              4               4
251         1              3               3
271         1              3               3
281         0              0               0
311         3              4               4
331         3              4               4
401         1              3               3
421         0              0               0
431         2              1               1
461         0              0               0
491         1              3               3
----------------------------------------------------------
PASS: 22/22 righe pubblicate concordano.
```

## Interpretazione scientifica

Il replay non dimostra la priorità storica del ponte e non sostituisce
la prova formale. Fornisce però un controllo esterno della
normalizzazione:

- il lato \(\operatorname{ind}_5(\varepsilon)\) riproduce esattamente i
  dati primari del 1985;
- il lato \(M_2\) viene calcolato direttamente dalla definizione
  ciclotomica;
- la relazione fra i due coincide su tutte le righe pubblicate.

Williams--Hardy possiedono il carattere quintico dell'unità aurea.
Il candidato contributo del progetto resta esclusivamente
l'identificazione di quel carattere con il momento quadratico della
struttura locale di Agrawal.
