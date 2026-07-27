# H4: matrice di chiusura formale

Questa matrice impedisce di confondere tre oggetti diversi:

1. un teorema universale dimostrato nel kernel Lean;
2. una riduzione il cui ponte algebrico deve ancora essere formalizzato;
3. un censimento finito riproducibile, che non implica H4.

H4 resta aperta.

| Claim | Status matematico | Lean | Certificato | Azione residua |
|---|---|---|---|---|
| `t ∣ gcd(gcd c d)(gcd a w)` se e solo se divide i quattro coefficienti | TEOREMA | completo: `dvd_fourCoefficientGcd_iff` | non necessario | nessuna |
| supporto intrinseco `(\Phi_m(\gamma),\gamma^k-\gamma')` = supporto dei quattro coefficienti, fuori da `p=5` | TEOREMA | completo: `primitiveFourVanish_iff_dvd_D`; entrambe le componenti split sono controllate | replay esatto nel box `r,s ≤ 30` | nessuna |
| dal supporto a quattro coefficienti al profilo d'ordine esatto `(4rs,2r,2s)` e agli scalari `(5,\varepsilon^2)` coordinati | TEOREMA | completo: `dvd_primitiveFourCoefficientD_exact_order_profile`, `dvd_D_exact_scalar_profile` | non necessario | nessuna |
| supporto originale intero `G_{r,s}` = supporto intrinseco, fuori da `10rs` | TEOREMA cartaceo da audit | il verso intrinseco→ordini è completo; l'integrità di `B_s` e il teorema del livello per il gcd intero restano paper-level | replay esatto nel box `r,s ≤ 30` | formalizzare l'intero ciclotomico aureo `B_s` e il suo teorema del livello |
| ricorrenza `γ^n = U_n γ - 5U_{n-1}` | TEOREMA | completo: `gamma_pow_formula` | replay Python esistente | nessuna |
| proprietà e unicità di `k_{r,s}` con le due condizioni gcd | TEOREMA elementare CRT | involuzione, coprimalità e unicità complete; l'esistenza uniforme resta separata | `kcanon` nei replay | formalizzare il costruttore CRT uniforme |
| un solo supporto dispari in `p-1=8q^e` forza uno dei due ordini a dividere 8 | TEOREMA | completo: `one_order_dvd_eight_of_single_odd_prime` | non necessario | formalizzare le due esclusioni finite |
| nessun primo split H con `p-1=8q^e` | TEOREMA | completo: `no_split_single_odd_support` | fattorizzazioni kernel-pure di `5^8-1` e `2205` | nessuna |
| `p=18 251 687` è primo inerte, `ord_p(5)=158`, e `p=k+4rs`; il secondo ordine è certificato dal replay matriciale | TEOREMA FINITO + CERTIFICATO | primalità, inerzia, firma, identità e ordine di 5 completi in `NoncanonicalWitness`; ordine matriciale nel replay v3 | replay v3 indipendente | formalizzare nel kernel il calcolo matriciale d'ordine `99 736` se si vuole rivendicarlo come dichiarazione Lean |
| il censimento p-first fino a `5·10^7` trova un solo caso `p>R_pE_p` | CERTIFICATO FINITO | non è un teorema universale Lean | sorgente, log e replay v3 | mantenere come artefatto computazionale |
| famiglia a due supporti, `q<t≤5000`, `p<10^18`: zero profili H | CERTIFICATO FINITO | non è un teorema universale Lean | sorgente, log e replay v3 | mantenere separata da H4 |
| ogni buon divisore di `D_{r,s}` è inerte | CONGETTURA EQUIVALENTE A H4 | non formalizzabile come teorema senza prova | zero hit nei domini censiti | aperta; mai introdurla come assioma |

## Gate per la pubblicazione

La pubblicazione è pronta soltanto quando:

- ogni riga marcata “TEOREMA” ha un puntatore a prova cartacea e, se
  dichiarata formalizzata, a una dichiarazione Lean;
- `#print axioms` mostra soltanto gli assiomi standard di Lean/mathlib;
- i certificati finiti dichiarano il dominio esatto e non sono usati per
  inferire vacuità universale;
- il ponte a quattro coefficienti non compare più come ipotesi opaca
  oppure è etichettato esplicitamente come teorema cartaceo non ancora
  formalizzato;
- H4 è sempre dichiarata aperta.
