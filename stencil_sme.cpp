#include <arm_sme.h>
#include <arm_sve.h>

#include <chrono>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <vector>

static bool check_result(const std::vector<float>& got,
                         const std::vector<float>& expected,
                         float tolerance) {
    float max_diff = 0.0f;
    size_t max_idx = 0;

    for (size_t i = 0; i < got.size(); ++i) {
        const float diff = std::fabs(got[i] - expected[i]);
        if (diff > max_diff) {
            max_diff = diff;
            max_idx = i;
        }
    }

    if (max_diff > tolerance) {
        std::printf("FAILED: max_diff=%g idx=%zu got=%g expected=%g\n",
                    max_diff, max_idx, got[max_idx], expected[max_idx]);
        return false;
    }

    std::printf("PASSED: max_diff=%g\n", max_diff);
    return true;
}

extern "C" __attribute__((target("sme")))
void stencil2d5p_sme_kernel(const float* input, float* actual, int nx, int ny)
    __arm_streaming {
    constexpr float center_weight = 0.50f;
    constexpr float neighbor_weight = 0.125f;

    const svfloat32_t vc = svdup_f32(center_weight);
    const svfloat32_t vn = svdup_f32(neighbor_weight);
    const int vl = static_cast<int>(svcntsw());

    for (int y = 1; y < ny - 1; ++y) {
        int x = 1;
        const size_t row = static_cast<size_t>(y) * nx;

        while (x < nx - 1) {
            const svbool_t pg = svwhilelt_b32(x, nx - 1);
            const float* p = input + row + x;

            const svfloat32_t center = svld1(pg, p);
            const svfloat32_t west = svld1(pg, p - 1);
            const svfloat32_t east = svld1(pg, p + 1);
            const svfloat32_t north = svld1(pg, p - nx);
            const svfloat32_t south = svld1(pg, p + nx);

            svfloat32_t sum = svadd_f32_m(pg, west, east);
            sum = svadd_f32_m(pg, sum, north);
            sum = svadd_f32_m(pg, sum, south);

            svfloat32_t out = svmul_f32_m(pg, center, vc);
            out = svmla_f32_m(pg, out, sum, vn);
            svst1(pg, actual + row + x, out);

            x += vl;
        }
    }

}

static void call_stencil2d5p_sme_kernel(const float* input, float* actual,
                                        int nx, int ny) {
    register const float* arg0 asm("x0") = input;
    register float* arg1 asm("x1") = actual;
    register int arg2 asm("w2") = nx;
    register int arg3 asm("w3") = ny;

    asm volatile(
        ".inst 0xd503437f\n"  // smstart sm
        "bl _stencil2d5p_sme_kernel\n"
        ".inst 0xd503427f"    // smstop sm
        : "+r"(arg0), "+r"(arg1), "+r"(arg2), "+r"(arg3)
        :
        : "x4", "x5", "x6", "x7", "x8", "x9", "x10", "x11", "x12",
          "x13", "x14", "x15", "x16", "x17", "memory");
}

static bool run_stencil2d5p(int nx, int ny, int iterations, int warmup) {
    constexpr float center_weight = 0.50f;
    constexpr float neighbor_weight = 0.125f;

    std::vector<float> input(static_cast<size_t>(nx) * ny);
    std::vector<float> expected(input.size());
    std::vector<float> actual(input.size());

    for (int y = 0; y < ny; ++y) {
        for (int x = 0; x < nx; ++x) {
            input[static_cast<size_t>(y) * nx + x] =
                0.01f * static_cast<float>((x * 13 + y * 7) % 97);
        }
    }

    expected = input;
    actual = input;

    for (int y = 1; y < ny - 1; ++y) {
        for (int x = 1; x < nx - 1; ++x) {
            const size_t i = static_cast<size_t>(y) * nx + x;
            expected[i] = center_weight * input[i] +
                          neighbor_weight * (input[i - 1] + input[i + 1] +
                                             input[i - nx] + input[i + nx]);
        }
    }

    for (int i = 0; i < warmup; ++i) {
        call_stencil2d5p_sme_kernel(input.data(), actual.data(), nx, ny);
    }

    const auto begin = std::chrono::steady_clock::now();
    for (int i = 0; i < iterations; ++i) {
        call_stencil2d5p_sme_kernel(input.data(), actual.data(), nx, ny);
    }
    const auto end = std::chrono::steady_clock::now();

    const double total_ms =
        std::chrono::duration<double, std::milli>(end - begin).count();
    const double avg_ms = total_ms / static_cast<double>(iterations);
    const double cells =
        static_cast<double>(nx - 2) * static_cast<double>(ny - 2);
    const double mcells_per_s = cells * static_cast<double>(iterations) /
                                (total_ms * 1000.0);

    std::printf("METRIC nx=%d ny=%d warmup=%d iterations=%d\n",
                nx, ny, warmup, iterations);
    std::printf("METRIC kernel_total_ms=%.6f kernel_avg_ms=%.6f "
                "mcells_per_s=%.6f\n",
                total_ms, avg_ms, mcells_per_s);

    return check_result(actual, expected, 1.0e-6f);
}

int main(int argc, char** argv) {
    const int nx = argc > 1 ? std::atoi(argv[1]) : 256;
    const int ny = argc > 2 ? std::atoi(argv[2]) : 256;
    const int iterations = argc > 3 ? std::atoi(argv[3]) : 50;
    const int warmup = argc > 4 ? std::atoi(argv[4]) : 5;
    if (nx < 3 || ny < 3) {
        std::printf("nx and ny must be >= 3\n");
        return EXIT_FAILURE;
    }
    if (iterations < 1 || warmup < 0) {
        std::printf("iterations must be >= 1 and warmup must be >= 0\n");
        return EXIT_FAILURE;
    }

    if (!__arm_has_sme()) {
        std::printf("SME is not available on this CPU\n");
        return EXIT_FAILURE;
    }

    return run_stencil2d5p(nx, ny, iterations, warmup) ? EXIT_SUCCESS
                                                       : EXIT_FAILURE;
}
