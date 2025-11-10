#include "gm_to_dirac_short.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * gm_to_dirac_approx_short<double> instance
 */
gm_to_dirac_short<double>* create_instance_gm_short_double() {
  return new gm_to_dirac_short<double>();
}
void delete_instance_gm_short_double(gm_to_dirac_short<double>* instance) {
  delete instance;
}

bool gm_short_double_approximate(
    gm_to_dirac_short<double>* instance, const double* covDiag, size_t L,
    size_t N, size_t bMax, double* x, const double* wX = nullptr,
    GslminimizerResult* result = nullptr,
    const ApproximateOptions& options = ApproximateOptions{}) {
  return instance->approximate(covDiag, L, N, bMax, x, wX, result, options);
}

#ifdef __cplusplus
}
#endif
