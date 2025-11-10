#include "dirac_to_dirac_approx_short.h"
#include "dirac_to_dirac_approx_short_function.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * dirac_to_dirac_approx_short<double> instance
 */
dirac_to_dirac_approx_short<double>* create_instance_dirac_short_double() {
  return new dirac_to_dirac_approx_short<double>();
}
void delete_instance_dirac_short_double(
    dirac_to_dirac_approx_short<double>* instance) {
  delete instance;
}

bool dirac_short_double_approximate(
    dirac_to_dirac_approx_short<double>* instance, const double* y, size_t M,
    size_t L, size_t N, size_t bMax, double* x, const double* wX = nullptr,
    const double* wY = nullptr, GslminimizerResult* result = nullptr,
    const ApproximateOptions& options = ApproximateOptions{}) {
  return instance->approximate(y, M, L, N, bMax, x, wX, wY, result, options);
}

/**
 * dirac_to_dirac_approx_short_function<double> instance
 */
dirac_to_dirac_approx_short_function<double>*
create_instance_dirac_dynamic_weight_double() {
  return new dirac_to_dirac_approx_short_function<double>();
}
void delete_instance_dirac_dynamic_weight_double(
    dirac_to_dirac_approx_short_function<double>* instance) {
  delete instance;
}

bool dirac_dynamic_weight_double_approximate(
    dirac_to_dirac_approx_short_function<double>* instance, const double* y,
    size_t M, size_t L, size_t N, size_t bMax, double* x,
    dirac_to_dirac_approx_short_function<double>::wXf wXcallback,
    dirac_to_dirac_approx_short_function<double>::wXd wXDcallback,
    GslminimizerResult* result = nullptr,
    const ApproximateOptions& options = ApproximateOptions{}) {
  return instance->approximate(y, M, L, N, bMax, x, wXcallback, wXDcallback,
                               result, options);
}

#ifdef __cplusplus
}
#endif
