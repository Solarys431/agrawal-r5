# H4 come intersezione ciclotomica di livelli

**Data:** 26 luglio 2026  
**Status complessivo:** riduzione universale dimostrata; box finito
certificato; congettura universale ancora aperta.

Questo fascicolo sostituisce la ricerca indiscriminata sui primi con un
bersaglio aritmetico esatto. Non dimostra H4. Dimostra però che H4 è
equivalente all'assenza di divisori primi split e primitivi in una
famiglia esplicita di massimi comuni divisori fra due valori
ciclotomici interi.

## 1. Notazione

Sia

\[
\varepsilon=\frac{1+\sqrt5}{2},
\qquad
x=\varepsilon^2=\frac{3+\sqrt5}{2}.
\]

Allora

\[
x^2-3x+1=0,\qquad N_{\mathbf Q(\sqrt5)/\mathbf Q}(x)=1,
\qquad \bar x=x^{-1}.
\]

Per \(r\ge1\) definiamo

\[
C_r=\Phi_{2r}(5)\in\mathbf Z.
\]

Per \(s\ge2\), posto \(m=2s\) e \(d=\varphi(m)/2\), definiamo

\[
B_s=x^{-d}\Phi_m(x).
\]

Poniamo inoltre \(B_1=1\). Infine:

\[
G_{r,s}=\gcd(C_r,B_s).
\]

Una coppia \((r,s)\) si dirà **ammissibile** quando

\[
\gcd(r,s)=1,\qquad r+s\equiv1\pmod2,\qquad 5\nmid rs.
\]

## 2. L'intero ciclotomico aureo

### Teorema 2.1 — integrità di \(B_s\) [TEOREMA]

Per ogni \(s\ge2\),

\[
B_s=x^{-\varphi(2s)/2}\Phi_{2s}(x)\in\mathbf Z.
\]

### Prova

1. Per \(m=2s>2\), il numero \(\varphi(m)\) è pari. Scriviamo
   \(2d=\varphi(m)\).
2. Il polinomio ciclotomico \(\Phi_m\) è reciproco:
   \[
   \Phi_m(X^{-1})=X^{-\varphi(m)}\Phi_m(X).
   \]
3. La coniugazione di \(\mathbf Q(\sqrt5)\) manda \(x\) in \(x^{-1}\).
   Quindi
   \[
   \overline{B_s}
   =(x^{-1})^{-d}\Phi_m(x^{-1})
   =x^d x^{-2d}\Phi_m(x)
   =B_s.
   \]
4. Pertanto \(B_s\in\mathbf Q\).
5. \(x\) è un'unità algebrica, quindi \(x^{-d}\) è un intero
   algebrico; anche \(\Phi_m(x)\) è un intero algebrico.
6. Ne segue che \(B_s\) è un intero algebrico razionale, dunque
   \(B_s\in\mathbf Z\). ∎

Il caso \(s=1\) viene separato perché \(\varphi(2)=1\); inoltre un
elemento \(x\) di ordine \(2\) soddisferebbe \(x=-1\), incompatibile con
\(x^2-3x+1=0\) fuori dalla caratteristica \(5\).

## 3. Il profilo scalare esatto

Sia \(p\ne2,5\) un primo split in \(\mathbf Q(\sqrt5)\), cioè
\((5/p)=1\). L'ordine di \(x\) non dipende dalla scelta della radice di
\(\sqrt5\), perché le due immagini di \(x\) sono inverse.

Indichiamo

\[
R=\operatorname{ord}_p(5),\qquad E=\operatorname{ord}_p(x).
\]

Il teorema di completezza scalare già formalizzato in Lean identifica
la presenza del trasporto locale di ordine quattro con l'esistenza di
un indice \(n\) tale che

\[
n\equiv4\pmod5,\qquad 5^{n-1}=-1,\qquad x^n=-1\pmod p.
\]

### Lemma 3.1 — CRT degli ordini [TEOREMA]

Esiste un tale \(n\) se e solo se

\[
R=2r,\qquad E=2s
\]

per una coppia ammissibile \((r,s)\).

### Prova

1. L'equazione \(5^{n-1}=-1\) implica che \(R\) è pari. Scriviamo
   \(R=2r\). Nel sottogruppo ciclico generato da \(5\), l'unico elemento
   di ordine due è \(5^r\); dunque
   \[
   n\equiv r+1\pmod{2r}.
   \]
2. Analogamente \(x^n=-1\) equivale, con \(E=2s\), a
   \[
   n\equiv s\pmod{2s}.
   \]
3. Le prime due congruenze sono compatibili se e solo se
   \[
   2\gcd(r,s)\mid r+1-s.
   \]
4. Se \(d=\gcd(r,s)\), il membro destro è congruo a \(1\pmod d\).
   Quindi la compatibilità forza \(d=1\).
5. Quando \(\gcd(r,s)=1\), la divisibilità per \(2\) equivale a
   \(r+1-s\) pari, ossia \(r+s\) dispari.
6. Se \(5\mid r\), la prima congruenza forza \(n\equiv1\pmod5\), in
   contraddizione con \(n\equiv4\pmod5\).
7. Se \(5\mid s\), la seconda forza \(n\equiv0\pmod5\), ancora
   impossibile.
8. Se \(5\nmid rs\), il modulo \(5\) è coprimo a \(2r\) e \(2s\);
   il teorema cinese completa il sistema con \(n\equiv4\pmod5\).
   ∎

## 4. Il teorema dei livelli

Useremo il fatto standard seguente: se \(p\nmid ma\) e
\(p\mid\Phi_m(a)\), allora l'ordine di \(a\bmod p\) è esattamente
\(m\). L'ipotesi \(p\nmid m\) è essenziale.

### Teorema 4.1 — intersezione ciclotomica esatta [TEOREMA]

Siano \(r,s\ge1\), sia \(p\ne2,5\) un primo split e supponiamo
\(p\nmid2rs\). Allora

\[
p\mid G_{r,s}
\quad\Longleftrightarrow\quad
\operatorname{ord}_p(5)=2r
\ \text{e}\
\operatorname{ord}_p(x)=2s.
\]

Per \(s=1\) entrambi i membri sono falsi.

### Prova

Per \(s\ge2\):

1. Se \(p\mid C_r=\Phi_{2r}(5)\), le ipotesi
   \(p\nmid10r\) e il lemma ciclotomico danno
   \[
   \operatorname{ord}_p(5)=2r.
   \]
2. Siccome \(p\) è split, \(x\) si riduce a un elemento non nullo di
   \(\mathbf F_p\).
3. \(x^{-\varphi(2s)/2}\) è un'unità modulo \(p\), perciò
   \[
   p\mid B_s
   \quad\Longleftrightarrow\quad
   \Phi_{2s}(x)=0\pmod p.
   \]
4. Da \(p\nmid2s\) e dal lemma ciclotomico segue
   \[
   \operatorname{ord}_p(x)=2s.
   \]
5. La conversa è immediata: un elemento di ordine esatto \(m\) è una
   radice di \(\Phi_m\), quindi le due divisibilità valgono e
   \(p\mid G_{r,s}\).

Per \(s=1\), \(B_1=1\), mentre \(x\) non può avere ordine \(2\) per
\(p\ne5\). ∎

### Lemma 4.2 — soglia dei fattori split [TEOREMA]

Sia \((r,s)\) ammissibile. Se un primo split \(p\nmid10rs\) divide
\(G_{r,s}\), allora

\[
p\equiv1\pmod{4rs}.
\]

In particolare \(p\ge4rs+1\).

### Prova

1. Dal Teorema 4.1, \(\operatorname{ord}_p(5)=2r\).
2. Poiché \(p\) è split, \(5\) è un quadrato modulo \(p\). In un gruppo
   ciclico questo significa che l'indice
   \((p-1)/(2r)\) è pari; dunque \(4r\mid p-1\).
3. Anche \(x=\varepsilon^2\) è un quadrato in \(\mathbf F_p^\times\).
   Da \(\operatorname{ord}_p(x)=2s\) segue analogamente
   \(4s\mid p-1\).
4. L'ammissibilità dà \(\gcd(r,s)=1\) e parità opposta. Pertanto
   \[
   \operatorname{lcm}(4r,4s)=4rs.
   \]
5. Ne segue \(4rs\mid p-1\). ∎

### Corollario 4.3 — forma esatta di H4 [TEOREMA DI RIDUZIONE]

H4 è equivalente alla seguente affermazione:

> per ogni coppia ammissibile \((r,s)\), ogni divisore primo split di
> \(G_{r,s}\) divide \(2rs\).

Equivalentemente, nessun \(G_{r,s}\) ammissibile possiede un divisore
primo \(p\) tale che

\[
\left(\frac5p\right)=1,\qquad p\nmid10rs.
\]

### Prova

1. Se H4 è falsa, il teorema di completezza scalare produce un primo
   split \(p\) e un indice \(n\equiv4\pmod5\) che soddisfano le due
   equazioni scalari.
2. Il Lemma 3.1 produce una coppia ammissibile \((r,s)\) con ordini
   \(2r,2s\).
3. Poiché entrambi gli ordini dividono \(p-1\), necessariamente
   \(p\nmid2rs\).
4. Il Teorema 4.1 dà \(p\mid G_{r,s}\).
5. Viceversa, un primo split \(p\nmid10rs\) che divide un
   \(G_{r,s}\) ammissibile ha gli ordini esatti \(2r,2s\).
6. Il Lemma 3.1 fornisce l'indice scalare; la completezza scalare
   formalizzata lo trasporta alla riga ciclotomica locale di ordine
   quattro. H4 è quindi falsa. ∎

### Corollario 4.4 — criterio sufficiente di taglia [TEOREMA]

Se per ogni coppia ammissibile vale

\[
G_{r,s}<4rs+1,
\]

allora H4 è vera.

Infatti ogni divisore primo di \(G_{r,s}\) è minore di \(4rs+1\),
mentre il Lemma 4.2 impone la soglia opposta a ogni divisore split
primitivo. Questo corollario non afferma che il bound uniforme sia
vero: lo isola come bersaglio sufficiente, più forte di H4.

I Corollari 4.3–4.4 sono il nuovo punto d'attacco. Non richiedono più di
scandire i primi e calcolarne due ordini: richiedono di controllare i
divisori primi di interi espliciti \(G_{r,s}\).

## 5. Certificato del box \(r,s\le5000\)

### Proposizione 5.1 [CERTIFICATO COMPUTAZIONALE FINITO]

Per tutte le \(6\,754\,610\) coppie ammissibili con
\(1\le r,s\le5000\), nessun \(G_{r,s}\) possiede un divisore primo
split.

Il calcolo ha prodotto:

| quantità | valore |
|---|---:|
| coppie ammissibili | 6.754.610 |
| gcd non banali | 717 |
| gcd compositi | 1 |
| massimo di \(G_{r,s}/(2rs)\) | \(3/4\), in \((r,s)=(1,2)\) |
| occorrenze di fattori primi | 718 |
| fattori inerti | 696 |
| fattori \(2\) o \(5\) | 22 |
| fattori split | 0 |
| errori di ricostruzione | 0 |
| errori di primalità | 0 |

Il certificatore usa PARI/GP con `factor_proven=1`, applica `isprime` a
ogni fattore e verifica `factorback` per ogni gcd fattorizzato.

File:

- `certifica_box_livelli_H.gp`;
- `esito_box_livelli_H_5000.txt`.

**Portata:** questa proposizione esclude tutti i profili H con
\(r,s\le5000\). Non pone un limite sul primo \(p\) e non dimostra la
congettura per livelli maggiori.

In tutto il box vale addirittura \(G_{r,s}<2rs\), e nessun fattore
raggiunge \(2rs+1\), mentre il Lemma 4.2 richiederebbe
\(p\ge4rs+1\) a un controesempio split. Questo margine è un dato
esplorativo certificato del box, non un teorema uniforme e non una
legge presunta.

## 6. Perché la scansione cieca dei primi viene arrestata

Lo scanner è stato prima regredito sull'intervallo storico completo
\(2\le p<10^9\):

- 25.422.719 primi split;
- 1.210.237 candidati diadici;
- massa attesa condizionata \(1{,}697309\);
- zero profili H.

Riproduce esattamente il censimento canonico della campagna. Sono stati
poi eseguiti tre falsificatori ulteriori:

1. intervallo completo
   \[
   10^9\le p<10^{10};
   \]
   202.100.126 primi split, 9.622.566 candidati diadici fattorizzati
   esattamente e zero profili completi. La massa attesa condizionata
   è \(0{,}217780\): il run supera il contratto minimo di
   falsificazione, ma l'esito nullo resta un certificato finito;
2. intervallo completo
   \[
   10^{12}\le p<1{,}01\cdot10^{12};
   \]
   180.914.104 primi split, 8.616.342 candidati diadici, zero profili
   completi;
3. famiglia completa dichiarata
   \(p-1=2^bN\), con \(N\) squarefree sostenuto sui primi specificati,
   \(10^9\le p<10^{18}\); 1.313.692 primi e zero profili completi.

Negli ultimi due casi il modello condizionato assegna massa attesa
molto inferiore a uno: rispettivamente \(9{,}37\cdot10^{-4}\) e
\(7{,}36\cdot10^{-4}\). Gli zeri sono quindi sanity checks, non
evidenza sostanziale nuova.

File:

- `scan_profili_H_intervallo.cpp`;
- `scan_profili_H_intervallo_v2.cpp`;
- `caccia_H_pmeno1_squarefree.cpp`;
- `esito_H_intervallo_2_1e9.json`;
- `esito_H_intervallo_1e9_1e10_v2.json`;
- `esito_H_intervallo_1e12_1p01e12.json`;
- `esito_H_pmeno1_squarefree_1e9_1e18.json`.

La versione `v2` conserva lo stesso rilevatore e aggiunge al certificato
il testimone che realizza il minimo gcd dei semiordini. Nel nuovo
intervallo è

\[
p=1\,368\,322\,369,\qquad
\operatorname{ord}_p(5)=6\,108\,582,\qquad
\operatorname{ord}_p(\varepsilon^2)=672.
\]

Quindi

\[
r=3\,054\,291,\qquad s=336,\qquad \gcd(r,s)=3.
\]

Il primo supera la serratura 2-adica a parità opposta e fallisce il
profilo H precisamente sulla coprimalità dispari. Primalità,
fattorizzazione di \(p-1\) e ordini esatti sono riprodotti, senza
dipendenze esterne, da `verify_H_near_miss.py`; l'output congelato è
`esito_H_near_miss_1368322369.json`. È un quasi-caso diagnostico, non
un controesempio a H4 e non una prova che un divisore comune dispari
esista sempre.

### Contratto d'arresto [DECISIONE METODOLOGICA]

- Non si alzano ulteriormente soglie prime senza una massa attesa
  dichiarata di almeno \(0{,}1\), oppure senza un nuovo teorema che
  selezioni una famiglia strutturalmente privilegiata.
- Il fronte computazionale principale diventa il box dei livelli
  \((r,s)\), perché certifica direttamente gli interi del Corollario
  4.3.
- Un fattore split \(p\nmid10rs\) chiuderebbe immediatamente H4 in
  senso negativo, con un controesempio verificabile.
- Una prova che tutti i fattori split di \(G_{r,s}\) dividono \(2rs\)
  chiuderebbe H4 in senso positivo.

## 7. Il muro residuo, in una riga

### Congettura d'inerzia dei gcd di livello [APERTA; EQUIVALENTE A H4]

Per ogni coppia ammissibile \((r,s)\),

\[
p\mid G_{r,s},\quad p\nmid10rs
\quad\Longrightarrow\quad
\left(\frac5p\right)=-1.
\]

Il problema è una intersezione di supporti ciclotomici a due livelli
mobili. I risultati classici sul support problem, sugli ordini medi e
sui gcd di successioni forniscono contesto e stime, ma non contengono
attualmente questa esclusione universale.

## 8. Collocazione rispetto alla letteratura

- A. Perucca, *Two variants of the support problem for products of
  abelian varieties and tori*, J. Number Theory 129 (2009),
  arXiv:0712.2815. Il teorema confronta ordini per quasi tutti i primi;
  i suoi quantificatori non coincidono con il nostro livello mobile.
- O. Järviniemi, *Orders of algebraic numbers in finite fields*,
  arXiv:2106.09813. Offre risultati di distribuzione sugli ordini,
  in larga parte sotto GRH, non una esclusione universale di
  intersezioni primitive.
- F. Campagna, G. A. Dill, R. Wilms, *Arithmetic unlikely
  intersections in powers of the multiplicative group*,
  arXiv:2607.15741. Il lavoro formula un quadro recente di intersezioni
  improbabili, prova il caso di dimensione uno e risultati parziali in
  dimensione due; non contiene automaticamente il Corollario 4.3 né la
  sua conclusione universale.

Queste citazioni spiegano perché il residuo è serio; non vengono usate
come ingredienti delle prove elementari dei §§2–4.

## 9. Status finale

| Claim | Status |
|---|---|
| \(B_s\in\mathbf Z\) | **TEOREMA** |
| profilo H \(\Longleftrightarrow\) coppia ammissibile di semiordini | **TEOREMA** |
| \(p\mid G_{r,s}\Longleftrightarrow\) ordini esatti, per \(p\nmid10rs\) split | **TEOREMA** |
| un fattore split primitivo soddisfa \(p\equiv1\pmod{4rs}\) | **TEOREMA** |
| H4 \(\Longleftrightarrow\) assenza di divisori split primitivi nei \(G_{r,s}\) | **TEOREMA DI RIDUZIONE** |
| il bound uniforme \(G_{r,s}<4rs+1\) implica H4 | **TEOREMA CONDIZIONALE; bound aperto** |
| nessun fattore split per \(r,s\le5000\) | **CERTIFICATO FINITO** |
| tutti i fattori dei \(G_{r,s}\) sono inerti o non primitivi | **APERTA; equivalente a H4** |

La vetta non è ancora dichiarata conquistata. È però localizzata:
l'ultimo muro è ora una sola famiglia di gcd interi, con un criterio
universale netto e un falsificatore diretto.
