#include <algorithm>
#include <atomic>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <map>
#include <numeric>
#include <omp.h>
#include <string>
#include <tuple>
#include <utility>
#include <vector>

using u64 = std::uint64_t;
using u128 = __uint128_t;

namespace {

u64 mul_mod(u64 a, u64 b, u64 modulus) {
    return static_cast<u64>(static_cast<u128>(a) * b % modulus);
}

u64 pow_mod(u64 base, u64 exponent, u64 modulus) {
    u64 result = 1;
    while (exponent != 0) {
        if ((exponent & 1U) != 0) {
            result = mul_mod(result, base, modulus);
        }
        base = mul_mod(base, base, modulus);
        exponent >>= 1U;
    }
    return result;
}

bool is_prime_64(u64 n) {
    if (n < 2) {
        return false;
    }
    for (u64 p : {2ULL, 3ULL, 5ULL, 7ULL, 11ULL, 13ULL, 17ULL,
                  19ULL, 23ULL, 29ULL, 31ULL, 37ULL}) {
        if (n % p == 0) {
            return n == p;
        }
    }

    const u64 d0 = n - 1;
    const unsigned shift = static_cast<unsigned>(__builtin_ctzll(d0));
    const u64 d = d0 >> shift;
    for (u64 a : {2ULL, 325ULL, 9375ULL, 28178ULL, 450775ULL,
                  9780504ULL, 1795265022ULL}) {
        if (a % n == 0) {
            continue;
        }
        u64 x = pow_mod(a % n, d, n);
        if (x == 1 || x == n - 1) {
            continue;
        }
        bool composite = true;
        for (unsigned r = 1; r < shift; ++r) {
            x = mul_mod(x, x, n);
            if (x == n - 1) {
                composite = false;
                break;
            }
        }
        if (composite) {
            return false;
        }
    }
    return true;
}

u64 splitmix64(u64& state) {
    u64 z = (state += 0x9e3779b97f4a7c15ULL);
    z = (z ^ (z >> 30U)) * 0xbf58476d1ce4e5b9ULL;
    z = (z ^ (z >> 27U)) * 0x94d049bb133111ebULL;
    return z ^ (z >> 31U);
}

u64 pollard_brent(u64 n, u64 seed) {
    if ((n & 1U) == 0) {
        return 2;
    }
    if (n % 3 == 0) {
        return 3;
    }

    for (;;) {
        u64 state = seed;
        const u64 y0 = splitmix64(state) % (n - 1) + 1;
        const u64 c = splitmix64(state) % (n - 1) + 1;
        const u64 batch = 128;
        u64 y = y0;
        u64 r = 1;
        u64 q = 1;
        u64 g = 1;
        u64 x = 0;
        u64 ys = 0;

        while (g == 1) {
            x = y;
            for (u64 i = 0; i < r; ++i) {
                y = (mul_mod(y, y, n) + c) % n;
            }
            u64 k = 0;
            while (k < r && g == 1) {
                ys = y;
                const u64 bound = std::min(batch, r - k);
                for (u64 i = 0; i < bound; ++i) {
                    y = (mul_mod(y, y, n) + c) % n;
                    const u64 difference = x > y ? x - y : y - x;
                    q = mul_mod(q, difference, n);
                }
                g = std::gcd(q, n);
                k += bound;
            }
            r <<= 1U;
        }

        if (g == n) {
            do {
                ys = (mul_mod(ys, ys, n) + c) % n;
                const u64 difference = x > ys ? x - ys : ys - x;
                g = std::gcd(difference, n);
            } while (g == 1);
        }
        if (g != n) {
            return g;
        }
        seed = splitmix64(state);
    }
}

void factor_recursive(u64 n, std::vector<u64>& factors, u64 seed) {
    if (n == 1) {
        return;
    }
    if (is_prime_64(n)) {
        factors.push_back(n);
        return;
    }
    const u64 divisor = pollard_brent(n, seed ^ n);
    factor_recursive(divisor, factors, seed + 0x517cc1b727220a95ULL);
    factor_recursive(n / divisor, factors, seed + 0x6eed0e9da4d94a4fULL);
}

[[maybe_unused]] std::vector<std::pair<u64, int>> factor_exact(u64 n) {
    std::vector<u64> flat;
    for (u64 p : {2ULL, 3ULL, 5ULL, 7ULL, 11ULL, 13ULL, 17ULL,
                  19ULL, 23ULL, 29ULL, 31ULL, 37ULL, 41ULL, 43ULL,
                  47ULL, 53ULL, 59ULL, 61ULL, 67ULL, 71ULL, 73ULL,
                  79ULL, 83ULL, 89ULL, 97ULL}) {
        while (n % p == 0) {
            flat.push_back(p);
            n /= p;
        }
    }
    if (n != 1) {
        factor_recursive(n, flat, n ^ 0xd1b54a32d192ed03ULL);
    }
    std::sort(flat.begin(), flat.end());

    std::vector<std::pair<u64, int>> result;
    for (u64 p : flat) {
        if (result.empty() || result.back().first != p) {
            result.push_back({p, 1});
        } else {
            ++result.back().second;
        }
    }
    return result;
}

// Algebra F_p[D]/(D^2 - 3D + 1), represented by aD + b.
struct QElem {
    u64 a;
    u64 b;
};

QElem q_mul(QElem x, QElem y, u64 p) {
    const u64 ac = mul_mod(x.a, y.a, p);
    const u64 ad = mul_mod(x.a, y.b, p);
    const u64 bc = mul_mod(x.b, y.a, p);
    const u64 bd = mul_mod(x.b, y.b, p);
    return {
        (mul_mod(3, ac, p) + ad + bc) % p,
        (bd + p - ac) % p,
    };
}

QElem q_pow(u64 exponent, u64 p) {
    QElem result{0, 1};
    QElem base{1, 0};
    while (exponent != 0) {
        if ((exponent & 1U) != 0) {
            result = q_mul(result, base, p);
        }
        base = q_mul(base, base, p);
        exponent >>= 1U;
    }
    return result;
}

bool q_is_one(QElem value) {
    return value.a == 0 && value.b == 1;
}

bool q_is_minus_one(QElem value, u64 p) {
    return value.a == 0 && value.b == p - 1;
}

int v2_order_5(u64 p) {
    const u64 group_order = p - 1;
    const int b = __builtin_ctzll(group_order);
    u64 value = pow_mod(5, group_order >> b, p);
    if (value == 1) {
        return 0;
    }
    int valuation = 0;
    while (value != 1) {
        value = mul_mod(value, value, p);
        ++valuation;
    }
    return valuation;
}

int v2_order_D(u64 p) {
    const u64 group_order = p - 1;
    const int b = __builtin_ctzll(group_order);
    QElem value = q_pow(group_order >> b, p);
    if (q_is_one(value)) {
        return 0;
    }
    int valuation = 0;
    while (!q_is_one(value)) {
        value = q_mul(value, value, p);
        ++valuation;
    }
    return valuation;
}

u64 exact_order_5(
    u64 p,
    const std::vector<std::pair<u64, int>>& factorization
) {
    u64 order = p - 1;
    for (const auto& [prime, exponent] : factorization) {
        for (int i = 0; i < exponent; ++i) {
            const u64 candidate = order / prime;
            if (pow_mod(5, candidate, p) != 1) {
                break;
            }
            order = candidate;
        }
    }
    return order;
}

u64 exact_order_D(
    u64 p,
    const std::vector<std::pair<u64, int>>& factorization
) {
    u64 order = p - 1;
    for (const auto& [prime, exponent] : factorization) {
        for (int i = 0; i < exponent; ++i) {
            const u64 candidate = order / prime;
            if (!q_is_one(q_pow(candidate, p))) {
                break;
            }
            order = candidate;
        }
    }
    return order;
}

[[maybe_unused]] std::vector<int> primes_up_to(int limit) {
    std::vector<std::uint8_t> composite(static_cast<std::size_t>(limit) + 1, 0);
    std::vector<int> primes;
    for (int i = 2; i <= limit; ++i) {
        if (composite[static_cast<std::size_t>(i)] != 0) {
            continue;
        }
        primes.push_back(i);
        if (static_cast<long long>(i) * i <= limit) {
            for (long long j = static_cast<long long>(i) * i;
                 j <= limit;
                 j += i) {
                composite[static_cast<std::size_t>(j)] = 1;
            }
        }
    }
    return primes;
}

struct CRT {
    bool ok;
    u64 residue;
    u64 modulus;
};

long long extended_gcd(
    long long a,
    long long b,
    long long& x,
    long long& y
) {
    if (b == 0) {
        x = 1;
        y = 0;
        return a;
    }
    long long x1 = 0;
    long long y1 = 0;
    const long long gcd = extended_gcd(b, a % b, x1, y1);
    x = y1;
    y = x1 - y1 * (a / b);
    return gcd;
}

CRT merge_crt(u64 a, u64 m, u64 b, u64 n) {
    const u64 gcd = std::gcd(m, n);
    const u64 difference = (b + n - (a % n)) % n;
    if (difference % gcd != 0) {
        return {false, 0, 0};
    }
    const u64 m1 = m / gcd;
    const u64 n1 = n / gcd;
    long long x = 0;
    long long y = 0;
    extended_gcd(static_cast<long long>(m1),
                 static_cast<long long>(n1), x, y);
    long long inverse = x % static_cast<long long>(n1);
    if (inverse < 0) {
        inverse += static_cast<long long>(n1);
    }
    const u64 t = n1 == 1
        ? 0
        : mul_mod((difference / gcd) % n1,
                  static_cast<u64>(inverse), n1);
    const u128 modulus128 = static_cast<u128>(m1) * n;
    if (modulus128 > std::numeric_limits<u64>::max()) {
        return {false, 0, 0};
    }
    const u64 modulus = static_cast<u64>(modulus128);
    const u64 residue = static_cast<u64>(
        (static_cast<u128>(m) * t + a) % modulus
    );
    return {true, residue, modulus};
}

struct Hit {
    u64 p;
    u64 order5;
    u64 orderD;
    u64 r;
    u64 s;
    u64 witness;
    int b;
    int v2_order5;
    int v2_orderD;
};

struct LocalStats {
    u64 split_primes = 0;
    u64 diadic_candidates = 0;
    u64 factorizations = 0;
    u64 coprime_half_orders = 0;
    u64 full_profiles = 0;
    u64 minimum_half_order_gcd = std::numeric_limits<u64>::max();
    long double expected_profiles = 0.0L;
    std::map<std::tuple<int, int, int, int>, u64> strata;
    std::map<std::tuple<int, int>, u64> support_sizes;
    std::map<u64, u64> small_gcd_histogram;
    std::vector<Hit> hits;
};

long double odd_independence_probability(
    const std::vector<std::pair<u64, int>>& factorization
) {
    long double probability = 1.0L;
    for (const auto& [prime, exponent] : factorization) {
        if (prime == 2) {
            continue;
        }
        long double prime_power = 1.0L;
        for (int i = 0; i < exponent; ++i) {
            prime_power *= static_cast<long double>(prime);
        }
        if (prime == 5) {
            probability /= prime_power * prime_power;
        } else {
            probability *=
                2.0L / prime_power - 1.0L / (prime_power * prime_power);
        }
    }
    return probability;
}

[[maybe_unused]] void append_json_string(
    std::ostream& output,
    const std::string& value
) {
    output << '"';
    for (char character : value) {
        if (character == '"' || character == '\\') {
            output << '\\';
        }
        output << character;
    }
    output << '"';
}

}  // namespace

#ifndef AGRAWAL_H_PROFILE_LIBRARY_ONLY
int main(int argc, char** argv) {
    if (argc < 4) {
        std::cerr
            << "usage: " << argv[0]
            << " LOW_INCLUSIVE HIGH_EXCLUSIVE OUTPUT_JSON [SEGMENT_SIZE]\n";
        return 2;
    }

    const u64 low_requested = std::strtoull(argv[1], nullptr, 10);
    const u64 high_requested = std::strtoull(argv[2], nullptr, 10);
    const std::string output_path = argv[3];
    const u64 segment_size = argc >= 5
        ? std::strtoull(argv[4], nullptr, 10)
        : 4000000ULL;

    if (low_requested >= high_requested ||
        high_requested > (1ULL << 62U) ||
        segment_size == 0) {
        std::cerr << "invalid interval or segment size\n";
        return 2;
    }
    const u64 low_global = std::max<u64>(2, low_requested);
    if (low_global >= high_requested) {
        std::cerr << "interval contains no candidate integer >= 2\n";
        return 2;
    }
    const long double base_limit_real =
        std::sqrt(static_cast<long double>(high_requested - 1)) + 1;
    if (base_limit_real >
        static_cast<long double>(std::numeric_limits<int>::max())) {
        std::cerr << "sieve base exceeds the supported int range\n";
        return 2;
    }
    const int base_limit = static_cast<int>(base_limit_real);
    const std::vector<int> base_primes = primes_up_to(base_limit);
    std::vector<LocalStats> locals(
        static_cast<std::size_t>(omp_get_max_threads())
    );
    std::atomic<u64> segments_done{0};
    const u64 interval_size = high_requested - low_global;
    const u64 segment_count =
        1 + (interval_size - 1) / segment_size;
    const auto started = std::chrono::steady_clock::now();

    for (u64 segment_low = low_global;
         segment_low < high_requested;
         segment_low += segment_size) {
        const u64 segment_high = segment_low +
            std::min(segment_size, high_requested - segment_low);
        std::vector<std::uint8_t> is_prime(
            static_cast<std::size_t>(segment_high - segment_low), 1
        );
        for (int prime_int : base_primes) {
            const u64 prime = static_cast<u64>(prime_int);
            const u128 square128 = static_cast<u128>(prime) * prime;
            if (square128 >= segment_high &&
                prime > (segment_high - 1) / prime) {
                break;
            }
            const u64 square = static_cast<u64>(square128);
            u64 start =
                ((segment_low + prime - 1) / prime) * prime;
            if (start < square) {
                start = square;
            }
            if (start >= segment_high) {
                continue;
            }
            for (u64 value = start;
                 value < segment_high;
                 value += prime) {
                is_prime[static_cast<std::size_t>(value - segment_low)] = 0;
            }
        }

        std::vector<u64> split_primes;
        for (u64 p = segment_low; p < segment_high; ++p) {
            if (p == 5 ||
                is_prime[static_cast<std::size_t>(p - segment_low)] == 0) {
                continue;
            }
            if (p % 5 == 1 || p % 5 == 4) {
                split_primes.push_back(p);
            }
        }

        #pragma omp parallel for schedule(dynamic, 128)
        for (std::size_t index = 0; index < split_primes.size(); ++index) {
            LocalStats& stats =
                locals[static_cast<std::size_t>(omp_get_thread_num())];
            const u64 p = split_primes[index];
            const int b = __builtin_ctzll(p - 1);
            const int a5 = v2_order_5(p);
            const int aD = v2_order_D(p);
            ++stats.split_primes;
            ++stats.strata[{b, static_cast<int>(p % 5), a5, aD}];

            const bool diadic =
                (a5 == 1 && aD >= 2) || (aD == 1 && a5 >= 2);
            if (!diadic) {
                continue;
            }
            ++stats.diadic_candidates;

            const auto factorization = factor_exact(p - 1);
            ++stats.factorizations;
            stats.expected_profiles +=
                odd_independence_probability(factorization);
            int odd_prime_support = 0;
            int odd_prime_support_without_5 = 0;
            for (const auto& [prime, exponent] : factorization) {
                (void)exponent;
                if (prime != 2) {
                    ++odd_prime_support;
                    if (prime != 5) {
                        ++odd_prime_support_without_5;
                    }
                }
            }
            ++stats.support_sizes[
                {odd_prime_support, odd_prime_support_without_5}
            ];

            const u64 order5 = exact_order_5(p, factorization);
            const u64 orderD = exact_order_D(p, factorization);
            if ((order5 & 1U) != 0 || (orderD & 1U) != 0) {
                std::cerr << "diadic/order inconsistency at p=" << p << "\n";
                std::abort();
            }
            const u64 r = order5 / 2;
            const u64 s = orderD / 2;
            const u64 half_order_gcd = std::gcd(r, s);
            stats.minimum_half_order_gcd =
                std::min(stats.minimum_half_order_gcd, half_order_gcd);
            if (half_order_gcd <= 1000) {
                ++stats.small_gcd_histogram[half_order_gcd];
            }
            if (half_order_gcd == 1) {
                ++stats.coprime_half_orders;
            }
            if (half_order_gcd != 1 ||
                ((r + s) & 1U) == 0 ||
                r % 5 == 0 ||
                s % 5 == 0) {
                continue;
            }

            CRT crt = merge_crt(
                s % (2 * s), 2 * s,
                (r + 1) % (2 * r), 2 * r
            );
            if (crt.ok) {
                crt = merge_crt(crt.residue, crt.modulus, 4, 5);
            }
            const u64 witness =
                crt.ok ? (crt.residue == 0 ? crt.modulus : crt.residue) : 0;
            if (!crt.ok ||
                witness % 5 != 4 ||
                pow_mod(5, witness - 1, p) != p - 1 ||
                !q_is_minus_one(q_pow(witness, p), p)) {
                std::cerr << "failed direct certificate at p=" << p << "\n";
                std::abort();
            }
            ++stats.full_profiles;
            stats.hits.push_back(
                {p, order5, orderD, r, s, witness, b, a5, aD}
            );
        }

        const u64 completed = ++segments_done;
        const auto now = std::chrono::steady_clock::now();
        const double elapsed =
            std::chrono::duration<double>(now - started).count();
        if (completed == segment_count || completed % 25 == 0) {
            std::cerr << "segment " << completed << "/" << segment_count
                      << " [" << segment_low << "," << segment_high << ")"
                      << " elapsed=" << std::fixed << std::setprecision(1)
                      << elapsed << "s\n";
        }
    }

    LocalStats total;
    for (LocalStats& stats : locals) {
        total.split_primes += stats.split_primes;
        total.diadic_candidates += stats.diadic_candidates;
        total.factorizations += stats.factorizations;
        total.coprime_half_orders += stats.coprime_half_orders;
        total.full_profiles += stats.full_profiles;
        total.minimum_half_order_gcd = std::min(
            total.minimum_half_order_gcd, stats.minimum_half_order_gcd
        );
        total.expected_profiles += stats.expected_profiles;
        for (const auto& [key, count] : stats.strata) {
            total.strata[key] += count;
        }
        for (const auto& [key, count] : stats.support_sizes) {
            total.support_sizes[key] += count;
        }
        for (const auto& [gcd, count] : stats.small_gcd_histogram) {
            total.small_gcd_histogram[gcd] += count;
        }
        total.hits.insert(
            total.hits.end(), stats.hits.begin(), stats.hits.end()
        );
    }
    std::sort(total.hits.begin(), total.hits.end(),
              [](const Hit& left, const Hit& right) {
                  return left.p < right.p;
              });

    const auto finished = std::chrono::steady_clock::now();
    const double elapsed =
        std::chrono::duration<double>(finished - started).count();
    std::ofstream output(output_path);
    if (!output) {
        std::cerr << "cannot open output: " << output_path << "\n";
        return 2;
    }
    output << std::setprecision(17);
    output << "{\n";
    output << "  \"schema\": 1,\n";
    output << "  \"program\": ";
    append_json_string(output, "scan_profili_H_intervallo.cpp");
    output << ",\n";
    output << "  \"low_inclusive\": " << low_requested << ",\n";
    output << "  \"high_exclusive\": " << high_requested << ",\n";
    output << "  \"segment_size\": " << segment_size << ",\n";
    output << "  \"openmp_threads\": " << omp_get_max_threads() << ",\n";
    output << "  \"coverage_complete\": true,\n";
    output << "  \"miller_rabin_deterministic_64_bit\": true,\n";
    output << "  \"factorization\": \"exact Pollard-Brent plus deterministic Miller-Rabin\",\n";
    output << "  \"elapsed_seconds\": " << elapsed << ",\n";
    output << "  \"split_primes\": " << total.split_primes << ",\n";
    output << "  \"diadic_candidates\": " << total.diadic_candidates << ",\n";
    output << "  \"exact_factorizations\": " << total.factorizations << ",\n";
    output << "  \"coprime_half_orders\": " << total.coprime_half_orders << ",\n";
    output << "  \"minimum_half_order_gcd\": ";
    if (total.minimum_half_order_gcd == std::numeric_limits<u64>::max()) {
        output << "null";
    } else {
        output << total.minimum_half_order_gcd;
    }
    output << ",\n";
    output << "  \"expected_H_conditioned_actual_2adic\": "
           << static_cast<double>(total.expected_profiles) << ",\n";
    output << "  \"full_H_profiles\": " << total.full_profiles << ",\n";
    output << "  \"small_gcd_histogram\": [";
    bool first = true;
    for (const auto& [gcd, count] : total.small_gcd_histogram) {
        if (!first) {
            output << ",";
        }
        first = false;
        output << "{\"gcd\":" << gcd << ",\"count\":" << count << "}";
    }
    output << "],\n";
    output << "  \"support_sizes\": [";
    first = true;
    for (const auto& [key, count] : total.support_sizes) {
        if (!first) {
            output << ",";
        }
        first = false;
        output << "{\"omega_odd\":" << std::get<0>(key)
               << ",\"omega_odd_without_5\":" << std::get<1>(key)
               << ",\"count\":" << count << "}";
    }
    output << "],\n";
    output << "  \"strata\": [";
    first = true;
    for (const auto& [key, count] : total.strata) {
        if (!first) {
            output << ",";
        }
        first = false;
        output << "{\"v2_p_minus_1\":" << std::get<0>(key)
               << ",\"p_mod_5\":" << std::get<1>(key)
               << ",\"v2_ord_5\":" << std::get<2>(key)
               << ",\"v2_ord_epsilon2\":" << std::get<3>(key)
               << ",\"count\":" << count << "}";
    }
    output << "],\n";
    output << "  \"hits\": [";
    first = true;
    for (const Hit& hit : total.hits) {
        if (!first) {
            output << ",";
        }
        first = false;
        output << "{\"p\":" << hit.p
               << ",\"ord_5\":" << hit.order5
               << ",\"ord_epsilon2\":" << hit.orderD
               << ",\"r\":" << hit.r
               << ",\"s\":" << hit.s
               << ",\"n_witness\":" << hit.witness
               << ",\"v2_p_minus_1\":" << hit.b
               << ",\"v2_ord_5\":" << hit.v2_order5
               << ",\"v2_ord_epsilon2\":" << hit.v2_orderD
               << ",\"direct_scalar_check\":true}";
    }
    output << "]\n";
    output << "}\n";

    std::cerr << "done split=" << total.split_primes
              << " diadic=" << total.diadic_candidates
              << " H=" << total.full_profiles
              << " elapsed=" << std::fixed << std::setprecision(2)
              << elapsed << "s\n";
    return 0;
}
#endif
