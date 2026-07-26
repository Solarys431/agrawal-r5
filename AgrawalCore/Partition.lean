/-
Nucleo Lean della campagna Agrawal — lotto 18: LA PARTIZIONE FORZATA.

Nel programma costruttivo del 25 luglio avevamo scoperto per via sperimentale
che i primi piccoli vanno divisi in due famiglie disgiunte — una ammessa a
dividere i `p−1`, l'altra i `p+1` — altrimenti `gcd(L,M) > 2` e il sistema
cinese muore. La trattavamo come un accorgimento tecnico di costruzione.

**Non è un accorgimento: è una necessità**, e vale per ogni numero che sia
simultaneamente di Carmichael e di Lucas–Carmichael.

La catena. Da `p−1 ∣ n−1` e `p+1 ∣ n+1` con `n = p·m` segue che entrambe le
condizioni si leggono su `m−1`, cioè `(p²−1)/2 ∣ n/p − 1`: è la forma
unificata già usata in tutta la campagna. Se un primo dispari `q` divide
`p²−1`, allora `q ∣ m−1`, cioè `n ≡ p (mod q)`. Se un secondo fattore `p'`
vede lo stesso `q`, allora `p ≡ n ≡ p' (mod q)`; ma se `q ∣ p−1` e
`q ∣ p'+1`, sottraendo si ottiene `q ∣ 2`, assurdo per `q` dispari.

  · `dvd_sub_of_korselt_pair` : entrambe le condizioni si leggono su `m−1`
  · `dvd_of_dvd_sq_sub_one`   : `q ∣ p²−1` ⟹ `q ∣ m−1`
  · `partition_forced`        : **il teorema** — nessun primo dispari può
                                dividere un `p−1` e un `p'+1` insieme
  · `three_dvd_sq_sub_one`    : 3 divide sempre `p²−1`, quindi il vincolo per
                                `q = 3` è universale: tutti i fattori sono
                                congrui fra loro modulo 3

Campagna UNICO, 26 luglio 2026.
-/
import Mathlib

namespace AgrawalCore

/-- **La forma unificata di Korselt.** Se `n = p·m` soddisfa
`p−1 ∣ n−1` (Carmichael) e `p+1 ∣ n+1` (Lucas–Carmichael), allora entrambe le
condizioni si leggono su `m−1`. -/
theorem dvd_sub_of_korselt_pair {p m : ℤ}
    (hcar : (p - 1) ∣ (p * m - 1)) (hluc : (p + 1) ∣ (p * m + 1)) :
    (p - 1) ∣ (m - 1) ∧ (p + 1) ∣ (m - 1) := by
  obtain ⟨c, hc⟩ := hcar
  obtain ⟨d, hd⟩ := hluc
  refine ⟨⟨c - m, by linarith [hc]⟩, ⟨m - d, by linarith [hd]⟩⟩

/-- Se un primo `q` divide `p²−1` e valgono le due condizioni di Korselt per
`p`, allora `q ∣ m−1`, cioè `n ≡ p (mod q)`. -/
theorem dvd_of_dvd_sq_sub_one {p m q : ℤ} (hq : Prime q)
    (hcar : (p - 1) ∣ (p * m - 1)) (hluc : (p + 1) ∣ (p * m + 1))
    (hdvd : q ∣ (p - 1) * (p + 1)) :
    q ∣ (m - 1) := by
  obtain ⟨h1, h2⟩ := dvd_sub_of_korselt_pair hcar hluc
  rcases hq.dvd_mul.mp hdvd with h | h
  · exact h.trans h1
  · exact h.trans h2

/-- **LA PARTIZIONE FORZATA.** Se un primo `q` divide `p−1` per un fattore e
`p'+1` per un altro, e se entrambi soddisfano le condizioni di Korselt
rispetto allo stesso `n`, allora `q ∣ 2`. Per `q` dispari è assurdo: i due
lati non possono coesistere, e ogni primo dispari sta o tutto fra i `p−1` o
tutto fra i `p+1`. -/
theorem partition_forced {p p' m m' q : ℤ} (hq : Prime q)
    (hcar : (p - 1) ∣ (p * m - 1)) (hluc : (p + 1) ∣ (p * m + 1))
    (hcar' : (p' - 1) ∣ (p' * m' - 1)) (hluc' : (p' + 1) ∣ (p' * m' + 1))
    (hsame : p * m = p' * m')
    (hleft : q ∣ (p - 1)) (hright : q ∣ (p' + 1)) :
    q ∣ 2 := by
  -- n ≡ p (mod q) da sinistra, n ≡ p' (mod q) da destra
  have hp : q ∣ (m - 1) := (dvd_of_dvd_sq_sub_one hq hcar hluc (hleft.mul_right _))
  have hp' : q ∣ (m' - 1) := (dvd_of_dvd_sq_sub_one hq hcar' hluc' (hright.mul_left _))
  -- n − p = p·m − p = p(m−1), quindi q ∣ n − p; analogamente q ∣ n − p'
  have h1 : q ∣ (p * m - p) := by
    have : p * m - p = p * (m - 1) := by ring
    exact this ▸ hp.mul_left p
  have h2 : q ∣ (p' * m' - p') := by
    have : p' * m' - p' = p' * (m' - 1) := by ring
    exact this ▸ hp'.mul_left p'
  -- da q ∣ n−p e q ∣ n−p' segue q ∣ p' − p
  have h3 : q ∣ (p' - p) := by
    have : p' - p = (p * m - p) - (p' * m' - p') := by rw [hsame]; ring
    exact this ▸ dvd_sub h1 h2
  -- e da q ∣ p−1, q ∣ p'+1 segue q ∣ (p'+1) − (p−1) = (p'−p) + 2
  have h4 : q ∣ ((p' + 1) - (p - 1)) := dvd_sub hright hleft
  have : (2 : ℤ) = ((p' + 1) - (p - 1)) - (p' - p) := by ring
  exact this ▸ dvd_sub h4 h3

/-- Tre divide sempre `p²−1` per `p` non multiplo di 3: il vincolo della
partizione per `q = 3` è dunque universale, e in un Carmichael ∩
Lucas–Carmichael tutti i fattori primi sono congrui fra loro modulo 3. -/
theorem three_dvd_sq_sub_one {p : ℤ} (hp : ¬ ((3 : ℤ) ∣ p)) :
    (3 : ℤ) ∣ (p - 1) * (p + 1) := by
  have h : p % 3 = 1 ∨ p % 3 = 2 := by omega
  rcases h with h | h
  · exact Dvd.dvd.mul_right (by omega) _
  · exact Dvd.dvd.mul_left (by omega) _

end AgrawalCore
