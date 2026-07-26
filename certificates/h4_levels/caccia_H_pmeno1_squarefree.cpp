#define AGRAWAL_H_PROFILE_LIBRARY_ONLY
#include "scan_profili_H_intervallo.cpp"

namespace {

struct SmoothOddPart {
    u64 value;
    u64 mask;
};

struct NearProfile {
    u64 p;
    u64 odd_part;
    u64 order5;
    u64 orderD;
    u64 half_order_gcd;
    int b;
};

struct SmoothStats {
    u64 primality_tests = 0;
    u64 primes = 0;
    u64 diadic_candidates = 0;
    u64 coprime_half_orders = 0;
    u64 full_profiles = 0;
    u64 minimum_half_order_gcd = std::numeric_limits<u64>::max();
    long double expected_profiles_after_diadic = 0.0L;
    std::vector<Hit> hits;
    std::vector<NearProfile> near_profiles;
};

void generate_odd_parts(
    const std::vector<u64>& support_primes,
    std::size_t index,
    u64 product,
    u64 mask,
    u64 maximum_odd_part,
    std::vector<SmoothOddPart>& output
) {
    if (index == support_primes.size()) {
        if (mask != 0) {
            output.push_back({product, mask});
        }
        return;
    }
    generate_odd_parts(
        support_primes, index + 1, product, mask,
        maximum_odd_part, output
    );
    const u64 prime = support_primes[index];
    if (product <= maximum_odd_part / prime) {
        generate_odd_parts(
            support_primes, index + 1, product * prime,
            mask | (1ULL << index), maximum_odd_part, output
        );
    }
}

std::vector<std::pair<u64, int>> known_factorization(
    int b,
    u64 mask,
    const std::vector<u64>& support_primes
) {
    std::vector<std::pair<u64, int>> factorization{{2, b}};
    for (std::size_t index = 0; index < support_primes.size(); ++index) {
        if ((mask & (1ULL << index)) != 0) {
            factorization.push_back({support_primes[index], 1});
        }
    }
    return factorization;
}

}  // namespace

int main(int argc, char** argv) {
    const u64 minimum_p = argc >= 2
        ? std::strtoull(argv[1], nullptr, 10)
        : 1000000000ULL;
    const u64 maximum_p = argc >= 3
        ? std::strtoull(argv[2], nullptr, 10)
        : 1000000000000000ULL;
    const std::string output_path = argc >= 4
        ? argv[3]
        : "esito_H_pmeno1_squarefree.json";
    const int support_count = argc >= 5
        ? std::atoi(argv[4])
        : 21;

    const std::vector<u64> available_primes{
        3, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43,
        47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101,
        103, 107, 109, 113, 127, 131, 137, 139, 149, 151,
    };
    if (minimum_p >= maximum_p ||
        maximum_p > 3000000000000000000ULL ||
        support_count < 1 ||
        support_count > static_cast<int>(available_primes.size()) ||
        support_count > 63) {
        std::cerr << "invalid arguments\n";
        return 2;
    }
    const std::vector<u64> support_primes(
        available_primes.begin(),
        available_primes.begin() + support_count
    );
    const u64 maximum_odd_part = (maximum_p - 1) / 8;
    std::vector<SmoothOddPart> odd_parts;
    const std::size_t reserve_count =
        support_count < 25 ? (1ULL << support_count) : (1ULL << 24);
    odd_parts.reserve(reserve_count);
    generate_odd_parts(
        support_primes, 0, 1, 0, maximum_odd_part, odd_parts
    );
    std::sort(
        odd_parts.begin(), odd_parts.end(),
        [](const SmoothOddPart& left, const SmoothOddPart& right) {
            return left.value < right.value;
        }
    );

    std::vector<SmoothStats> locals(
        static_cast<std::size_t>(omp_get_max_threads())
    );
    const auto started = std::chrono::steady_clock::now();

    #pragma omp parallel for schedule(dynamic, 256)
    for (std::size_t candidate_index = 0;
         candidate_index < odd_parts.size();
         ++candidate_index) {
        SmoothStats& stats =
            locals[static_cast<std::size_t>(omp_get_thread_num())];
        const SmoothOddPart candidate = odd_parts[candidate_index];
        const int minimum_b = 3;
        for (int b = minimum_b; b < 62; ++b) {
            const u128 shifted =
                static_cast<u128>(candidate.value) << b;
            if (shifted + 1 > maximum_p) {
                break;
            }
            const u64 p = static_cast<u64>(shifted + 1);
            if (p < minimum_p || p % 5 != 4) {
                continue;
            }
            ++stats.primality_tests;
            if (!is_prime_64(p)) {
                continue;
            }
            ++stats.primes;

            const int a5 = v2_order_5(p);
            const int aD = v2_order_D(p);
            const bool diadic =
                (a5 == 1 && aD >= 2) || (aD == 1 && a5 >= 2);
            if (!diadic) {
                continue;
            }
            ++stats.diadic_candidates;

            const auto factorization =
                known_factorization(b, candidate.mask, support_primes);
            stats.expected_profiles_after_diadic +=
                odd_independence_probability(factorization);
            const u64 order5 = exact_order_5(p, factorization);
            const u64 orderD = exact_order_D(p, factorization);
            const u64 r = order5 / 2;
            const u64 s = orderD / 2;
            const u64 half_order_gcd = std::gcd(r, s);
            stats.minimum_half_order_gcd =
                std::min(stats.minimum_half_order_gcd, half_order_gcd);
            if (half_order_gcd <= 1000) {
                stats.near_profiles.push_back(
                    {p, candidate.value, order5, orderD,
                     half_order_gcd, b}
                );
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
    }

    SmoothStats total;
    for (SmoothStats& stats : locals) {
        total.primality_tests += stats.primality_tests;
        total.primes += stats.primes;
        total.diadic_candidates += stats.diadic_candidates;
        total.coprime_half_orders += stats.coprime_half_orders;
        total.full_profiles += stats.full_profiles;
        total.minimum_half_order_gcd = std::min(
            total.minimum_half_order_gcd, stats.minimum_half_order_gcd
        );
        total.expected_profiles_after_diadic +=
            stats.expected_profiles_after_diadic;
        total.hits.insert(
            total.hits.end(), stats.hits.begin(), stats.hits.end()
        );
        total.near_profiles.insert(
            total.near_profiles.end(),
            stats.near_profiles.begin(), stats.near_profiles.end()
        );
    }
    std::sort(
        total.hits.begin(), total.hits.end(),
        [](const Hit& left, const Hit& right) {
            return left.p < right.p;
        }
    );
    std::sort(
        total.near_profiles.begin(), total.near_profiles.end(),
        [](const NearProfile& left, const NearProfile& right) {
            return std::tie(left.half_order_gcd, left.p) <
                   std::tie(right.half_order_gcd, right.p);
        }
    );
    if (total.near_profiles.size() > 1000) {
        total.near_profiles.resize(1000);
    }

    const auto finished = std::chrono::steady_clock::now();
    const double elapsed =
        std::chrono::duration<double>(finished - started).count();
    std::ofstream output(output_path);
    output << std::setprecision(17);
    output << "{\n";
    output << "  \"schema\": 1,\n";
    output << "  \"search_family\": \"p-1=2^b*N with N squarefree on the declared support\",\n";
    output << "  \"coverage_complete_for_family\": true,\n";
    output << "  \"minimum_p\": " << minimum_p << ",\n";
    output << "  \"maximum_p\": " << maximum_p << ",\n";
    output << "  \"support_primes\": [";
    for (std::size_t i = 0; i < support_primes.size(); ++i) {
        if (i != 0) {
            output << ",";
        }
        output << support_primes[i];
    }
    output << "],\n";
    output << "  \"odd_parts\": " << odd_parts.size() << ",\n";
    output << "  \"primality_tests\": " << total.primality_tests << ",\n";
    output << "  \"prime_candidates\": " << total.primes << ",\n";
    output << "  \"diadic_candidates\": " << total.diadic_candidates << ",\n";
    output << "  \"coprime_half_orders\": "
           << total.coprime_half_orders << ",\n";
    output << "  \"minimum_half_order_gcd\": ";
    if (total.minimum_half_order_gcd == std::numeric_limits<u64>::max()) {
        output << "null";
    } else {
        output << total.minimum_half_order_gcd;
    }
    output << ",\n";
    output << "  \"expected_H_conditioned_actual_2adic\": "
           << static_cast<double>(total.expected_profiles_after_diadic)
           << ",\n";
    output << "  \"full_H_profiles\": " << total.full_profiles << ",\n";
    output << "  \"elapsed_seconds\": " << elapsed << ",\n";
    output << "  \"near_profiles\": [";
    bool first = true;
    for (const NearProfile& near : total.near_profiles) {
        if (!first) {
            output << ",";
        }
        first = false;
        output << "{\"p\":" << near.p
               << ",\"odd_part\":" << near.odd_part
               << ",\"b\":" << near.b
               << ",\"ord_5\":" << near.order5
               << ",\"ord_epsilon2\":" << near.orderD
               << ",\"half_order_gcd\":" << near.half_order_gcd
               << "}";
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
               << ",\"direct_scalar_check\":true}";
    }
    output << "]\n";
    output << "}\n";

    std::cerr << "odd_parts=" << odd_parts.size()
              << " tests=" << total.primality_tests
              << " primes=" << total.primes
              << " diadic=" << total.diadic_candidates
              << " expected=" << std::setprecision(8)
              << static_cast<double>(total.expected_profiles_after_diadic)
              << " H=" << total.full_profiles
              << " elapsed=" << elapsed << "s\n";
    return 0;
}
