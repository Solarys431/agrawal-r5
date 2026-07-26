\\ Certificato indipendente del box dei livelli per il profilo H.
\\
\\ Per m = 2s > 2 si usa il fattore ciclotomico aureo intero
\\
\\   B_s = x^(-phi(m)/2) Phi_m(x),  x^2 - 3x + 1 = 0.
\\
\\ Un profilo H split con ord_p(5)=2r e ord_p(epsilon^2)=2s
\\ forza p | gcd(Phi_(2r)(5), B_s), con
\\ gcd(r,s)=1, r+s dispari e 5 non divisore di rs.
\\
\\ Lo script calcola tutte le intersezioni nel box 1 <= r,s <= N,
\\ prova la primalita' di ogni fattore e registra separatamente ogni
\\ fattore split. Un fattore split e' soltanto un candidato: prima di
\\ confutare H4 occorre ancora il controllo degli ordini esatti nel
\\ caso non primitivo p | 2rs.

default(factor_proven, 1);
default(parisizemax, 4000000000);
default(parisize, 1000000000);
N = 5000;

x = 'x;
X = Mod(x, x^2 - 3*x + 1);

make_B(s) =
{
  if (s == 1, return(1));
  my(m = 2*s, half_degree = eulerphi(2*s)/2);
  my(reduced = lift(subst(polcyclo(m), x, X) * X^(-half_degree)));
  if (poldegree(reduced) > 0,
    error("normalizzazione aurea non costante al livello ", s));
  return(polcoeff(reduced, 0));
};

B = vector(N, s, make_B(s));
C = vector(N, r, subst(polcyclo(2*r), x, 5));

nontrivial = 0;
admissible_pairs = 0;
composite_gcd = 0;
split_factors = 0;
nonprimitive_split = 0;
inert_factors = 0;
exceptional_factors = 0;
prime_factor_rows = 0;
factors_above_level_modulus = 0;
maximum_digits = 0;
reconstruction_failures = 0;
primality_failures = 0;
maximum_ratio_numerator = 0;
maximum_ratio_denominator = 1;
maximum_ratio_r = 0;
maximum_ratio_s = 0;

inspect_factor(r, s, g, p, exponent) =
{
  prime_factor_rows++;
  if (!isprime(p),
    primality_failures++;
    error("fattore non provato primo: r=", r, " s=", s, " p=", p));
  if (p >= 2*r*s + 1, factors_above_level_modulus++);
  if (p == 2 || p == 5,
    exceptional_factors++;
    return()
  );
  if (p%5 == 2 || p%5 == 3,
    inert_factors++;
    return()
  );
  split_factors++;
  if ((2*r*s)%p == 0, nonprimitive_split++);
  print("SPLIT_CANDIDATE r=", r, " s=", s, " p=", p,
        " exponent=", exponent, " p_divides_2rs=", (2*r*s)%p == 0,
        " gcd=", g);
};

inspect_pair(r, s) =
{
  if (gcd(r, s) != 1 || (r+s)%2 == 0 || r%5 == 0 || s%5 == 0,
    return());

  admissible_pairs++;
  my(g = gcd(C[r], B[s]));
  if (g == 1, return());

  nontrivial++;
  maximum_digits = max(maximum_digits, #Str(g));
  if (g*maximum_ratio_denominator >
      maximum_ratio_numerator*(2*r*s),
    maximum_ratio_numerator = g;
    maximum_ratio_denominator = 2*r*s;
    maximum_ratio_r = r;
    maximum_ratio_s = s);
  if (!isprime(g), composite_gcd++);

  my(factors = factor(g));
  if (factorback(factors) != g,
    reconstruction_failures++;
    error("ricostruzione fallita: r=", r, " s=", s, " gcd=", g));
  for (row = 1, matsize(factors)[1],
    inspect_factor(r, s, g, factors[row, 1], factors[row, 2]));
};

for (r = 1, N, for (s = 1, N, inspect_pair(r, s)));

print("BOX_LEVEL_CERTIFICATE");
print("N=", N);
print("PAIRS_TESTED_DOMAIN=gcd(r,s)=1,r+s odd,5 does not divide r*s");
print("ADMISSIBLE_PAIRS=", admissible_pairs);
print("NONTRIVIAL_GCDS=", nontrivial);
print("COMPOSITE_GCDS=", composite_gcd);
print("MAXIMUM_GCD_DECIMAL_DIGITS=", maximum_digits);
print("MAXIMUM_GCD_OVER_2RS_NUMERATOR=", maximum_ratio_numerator);
print("MAXIMUM_GCD_OVER_2RS_DENOMINATOR=", maximum_ratio_denominator);
print("MAXIMUM_GCD_OVER_2RS_PAIR=", maximum_ratio_r, ",", maximum_ratio_s);
print("PRIME_FACTOR_ROWS=", prime_factor_rows);
print("INERT_PRIME_FACTORS=", inert_factors);
print("EXCEPTIONAL_FACTORS_2_OR_5=", exceptional_factors);
print("FACTORS_AT_LEAST_2RS_PLUS_1=", factors_above_level_modulus);
print("SPLIT_PRIME_FACTORS=", split_factors);
print("NONPRIMITIVE_SPLIT_FACTORS=", nonprimitive_split);
print("RECONSTRUCTION_FAILURES=", reconstruction_failures);
print("PRIMALITY_FAILURES=", primality_failures);
print("FACTOR_PROVEN=", default(factor_proven));
