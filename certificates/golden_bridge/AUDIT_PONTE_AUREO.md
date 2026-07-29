# Audit indipendente del ponte aureo

**Repository auditato:** `Solarys431/agrawal-r5`  
**Commit:** `5e894ab98bc7f6c89969d83e52d8b2493031a3e1`  
**Data dell'audit:** 29 luglio 2026

## Verdetto

\[
\boxed{\text{IL PONTE AUREO È MATEMATICAMENTE CORRETTO}}
\]

Il risultato esatto è:

\[
\boxed{
M_2=3\,\chi(\varepsilon)
}
\]

dove:

- \(p\equiv1\pmod5\) è primo;
- \(\zeta\in\mathbf F_p^\times\) ha ordine \(5\);
- \(u_a=\zeta^a-1\), \(a\in(\mathbf Z/5\mathbf Z)^\times\);
- \(\chi:\mathbf F_p^\times\to\mathbf Z/5\mathbf Z\) è un unico e
  medesimo carattere quintico;
- \(\varepsilon=1+\zeta+\zeta^4=(1+\sqrt5)/2\);
- \(M_2=\sum_a a^2\chi(u_a)\).

Il nucleo fattoriale e l'interfaccia prodotto--somma sono verificati
dal kernel Lean. La derivazione completa dalla riga locale di Agrawal
alla covarianza dei quattro caratteri è corretta come matematica, ma
non è ancora confezionata in un singolo teorema Lean end-to-end nel
commit auditato.

## 1. Dalla congruenza locale alle quattro righe

Sia
\[
S(p,5)=\{m\ge1:(X-1)^m=X^m-1
\text{ in }\mathbf F_p[X]/(\Phi_5)\}.
\]

Per \(m\in S(p,5)\), valutando la divisibilità polinomiale nelle quattro
radici primitive \(\zeta^a\), si ottiene:
\[
\boxed{
(\zeta^a-1)^m=\zeta^{am}-1
}
\qquad
(a\in(\mathbf Z/5\mathbf Z)^\times).
\tag{1.1}
\]

Se
\[
t=m\bmod5,
\]
la (1.1) è:
\[
u_a^m=u_{ta}.
\tag{1.2}
\]

Questo passaggio non richiede un logaritmo discreto.

## 2. Covarianza mediante un carattere quintico

Applichiamo lo stesso carattere quintico
\[
\chi:\mathbf F_p^\times\longrightarrow\mathbf Z/5\mathbf Z
\]
a entrambi i membri della (1.2). Ponendo:
\[
e(a)=\chi(u_a),
\]
si ottiene:
\[
e(ta)=\chi(u_a^m)=m\chi(u_a)=t\,e(a).
\]

Quindi:
\[
\boxed{e(ta)=t\,e(a).}
\tag{2.1}
\]

Questa formulazione è più pulita della scelta di una radice primitiva
\(\gamma\) e dei logaritmi \(e_a=\log_\gamma(u_a)\): evita interamente
il problema di coordinare \(\gamma\), \(\zeta\) e la normalizzazione
dell'indice.

## 3. Ostruzione dei momenti

Definiamo:
\[
M_j=\sum_{a\in\mathbf F_5^\times}a^j e(a).
\]

Dalla (2.1), con il cambio di variabile \(b=ta\):
\[
tM_j
=
\sum_a a^j e(ta)
=
\sum_b(t^{-1}b)^j e(b)
=
t^{-j}M_j.
\]

Pertanto:
\[
\boxed{(t^{j+1}-1)M_j=0.}
\tag{3.1}
\]

Per \(j=2\):
\[
(t^3-1)M_2=0.
\]

In \(\mathbf F_5^\times\), nessun \(t\ne1\) soddisfa \(t^3=1\).
Dunque:
\[
\boxed{
t\ne1\Longrightarrow M_2=0.
}
\tag{3.2}
\]

Per \(j=0\), analogamente:
\[
t\ne1\Longrightarrow M_0=0.
\tag{3.3}
\]

## 4. Fattorizzazione aurea

Poniamo:
\[
A=(\zeta-1)(\zeta^4-1),
\qquad
B=(\zeta^2-1)(\zeta^3-1).
\]

Dalla relazione ciclotomica:
\[
1+\zeta+\zeta^2+\zeta^3+\zeta^4=0
\]
si ricavano:
\[
AB=5,
\qquad
B=\sqrt5\,\varepsilon,
\qquad
(\sqrt5)^2=5.
\]

Il prodotto quadratico è:
\[
U_2=A\,B^4.
\]

Quindi:
\[
U_2=(AB)B^3
=5(\sqrt5\,\varepsilon)^3
=(\sqrt5)^5\varepsilon^3.
\]

Pertanto:
\[
\boxed{
U_2=(\sqrt5)^5\varepsilon^3.
}
\tag{4.1}
\]

Applicando \(\chi\):
\[
\chi(U_2)
=
5\chi(\sqrt5)+3\chi(\varepsilon)
=
3\chi(\varepsilon).
\]

L'interfaccia prodotto--somma dà:
\[
\chi(U_2)
=
\sum_a a^2\chi(u_a)
=
M_2.
\]

Segue:
\[
\boxed{
M_2=3\chi(\varepsilon).
}
\tag{4.2}
\]

Poiché \(3\ne0\) in \(\mathbf F_5\):
\[
\boxed{
M_2=0
\iff
\chi(\varepsilon)=0
\iff
\varepsilon\in(\mathbf F_p^\times)^5.
}
\tag{4.3}
\]

Inoltre:
\[
\prod_a u_a=\Phi_5(1)=5,
\]
quindi:
\[
M_0=\chi(5).
\tag{4.4}
\]

Combinando (3.2)--(4.4):

> Se una classe locale \(t=m\bmod5\) è non banale, allora \(5\) e
> \(\varepsilon\) sono simultaneamente residui quinti modulo \(p\).

Questo è il contenuto preciso del ponte tra la congruenza locale di
Agrawal e il carattere classico dell'unità aurea.

## 5. Indipendenza dalle scelte

### Cambio del carattere

Cambiare il generatore del gruppo moltiplicativo moltiplica \(\chi\)
per un elemento non nullo di \(\mathbf F_5\). Entrambi i lati di
\[
M_2=3\chi(\varepsilon)
\]
vengono moltiplicati per lo stesso scalare. La vanishing condition è
invariante.

### Cambio della radice quinta

Sostituire \(\zeta\) con \(\zeta^b\) permuta i quattro \(u_a\). Se
\(b\) scambia le due radici di \(T^2-T-1\), allora:
\[
\varepsilon\longmapsto-\varepsilon^{-1}.
\]
Poiché \(-1\) è una quinta potenza quando \(p\equiv1\pmod5\), il
criterio:
\[
\chi(\varepsilon)=0
\]
resta invariato. Anche l'identità esatta si trasforma coerentemente.

## 6. Stato Lean verificato

Nel commit auditato sono kernel-checked:

1. la fattorizzazione (4.1);
2. il passaggio da un prodotto pesato alla somma dei caratteri;
3. l'identificazione del prodotto a \(j=2\) con \(U_2\);
4. la composizione:
   \[
   M_2=3\chi(\varepsilon);
   \]
5. il lemma astratto di covarianza dei momenti;
6. le quattro righe letterali per il trasporto locale di ordine quattro.

Non è presente come singola dichiarazione kernel la catena:
\[
\texttt{LocalS5}
\Longrightarrow
e(ta)=t e(a)
\Longrightarrow
M_2=0
\Longrightarrow
\chi(\varepsilon)=0.
\]

Questa è una lacuna di **copertura formale**, non una lacuna della
dimostrazione matematica.

## 7. Due correzioni consigliate al paper

### Correzione A — normalizzazione dell'indice

La frase:

> “Let \(\operatorname{ind}_5(x)\) denote the quintic index with
> respect to \(z\)”

deve specificare che il momento e l'indice di \(\varepsilon\) usano lo
stesso carattere quintico. Formulazione consigliata:

> Fix a quintic character
> \(\chi:\mathbf F_p^\times\to\mathbf F_5\), and set
> \(e_a=\chi(\zeta^a-1)\). We write
> \(\operatorname{ind}_5(x)=\chi(x)\).

In alternativa, si devono coordinare esplicitamente:
\[
z=\gamma^{(p-1)/5}.
\]

### Correzione B — perimetro Lean

Nella dimostrazione del teorema della forma a logaritmi discreti, la
frase:

> “Full details (and the Lean formalization of this section) are in the
> project repository”

è troppo forte per il commit auditato.

Formulazione consigliata:

> The literal \(r=5\) row transport and the abstract moment obstruction
> are Lean-checked. The general decomposition/discrete-logarithm
> interface stated here remains paper-level.

## 8. Lemma Lean che chiuderebbe l'interfaccia

Il prossimo teorema da formalizzare dovrebbe avere il seguente
contenuto matematico:

### `localS5_quintic_character_covariance`

Sotto le ipotesi:

- \(p\) primo e \(5\mid p-1\);
- \(\zeta\in\mathbf F_p^\times\) di ordine \(5\);
- \(m\in S(p,5)\);
- \(t=m\bmod5\);
- \(\chi:\mathbf F_p^\times\to\mathbf Z/5\mathbf Z\) carattere quintico;

definendo:
\[
e(a)=\chi(\zeta^a-1),
\]
si ha:
\[
e(ta)=t e(a)
\quad
\text{per ogni }a\in\mathbf F_5^\times.
\]

Da questo e dai teoremi già presenti segue immediatamente:

### `nontrivial_local_class_implies_golden_fifth_power`

\[
t\ne1
\Longrightarrow
\chi(5)=0
\quad\text{e}\quad
\chi(\varepsilon)=0.
\]

Questa via è preferibile alla formalizzazione di un logaritmo discreto:
usa soltanto omomorfismi di gruppi, già presenti nel nucleo.

## 9. Replay indipendente

È stato eseguito un audit esaustivo per tutti i primi:
\[
p<10\,000,\qquad p\equiv1\pmod5.
\]

Risultati:

- primi controllati: \(306\);
- classi di esponente controllate: \(1\,158\,464\);
- classi locali trovate: \(387\);
- fallimenti del ponte: \(0\);
- classi locali non banali: una.

Il caso non banale è:
\[
p=5281,\qquad m=529,\qquad m\bmod5=4.
\]

In questo caso:
\[
\chi(5)=0,\qquad
\chi(\varepsilon)=0,\qquad
M_0=M_2=0,
\]
come previsto.

## 10. Novità

Williams--Hardy calcolano il carattere quintico classico dell'unità
aurea. Quel risultato non è nuovo.

Il contributo potenzialmente nuovo è la catena:
\[
\text{momento quadratico locale di Agrawal}
=
\chi(U_2)
=
3\chi(\varepsilon).
\]

La ricerca mirata documentata nel repository e l'audit indipendente non
hanno trovato questa identificazione esplicita nella letteratura
esaminata. La formulazione scientificamente corretta resta:

> To the best of our knowledge, the explicit identification of
> Agrawal's quadratic local moment with three times the quintic
> character of the golden unit does not appear in the sources examined.
> Historical priority remains subject to specialist review.

## Conclusione

Il ponte aureo non è un'analogia e non dipende da dati sperimentali.
È una concatenazione esatta di:

1. valutazione della congruenza locale nelle radici quinte;
2. applicazione di un carattere quintico;
3. ostruzione dei momenti;
4. fattorizzazione ciclotomica aurea.

La matematica è corretta. Restano da completare:

- un teorema Lean end-to-end dalla riga locale al carattere;
- due chiarimenti di formulazione nel paper;
- la revisione storica da parte di uno specialista.
