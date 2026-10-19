/* Exact Hamiltonian Monte Carlo for z ~ N(0, Sigma) restricted to the orthant z > 0
 * (Pakman & Paninski 2014, "Exact HMC for truncated multivariate Gaussians").
 *
 * Work in whitened coordinates xi (z = C xi, C C^T = Sigma).  The Hamiltonian
 * |xi|^2/2 + |v|^2/2 gives xi(t) = xi0 cos t + v0 sin t; constraint i is c_i.xi >= 0,
 * with c_i row i of C.  Mapping everything back to z-space:
 *   z(t) = a cos t + b sin t,  a = z0, b = C v0 ~ N(0, Sigma),
 * and the reflection off wall j is  b <- b - 2 (b_j / Sigma_jj) Sigma[:, j].
 * Momenta b (one row per iteration, already distributed N(0,Sigma)) are passed in.
 * Compile: gcc -O3 -march=native -shared -fPIC -o hmc_orthant.so hmc_orthant.c -lm
 */
#include <math.h>
#include <stdlib.h>
#include <string.h>

long hmc_orthant(int n, const double *Sigma, double *z, int iters, const double *W,
                 double T, double *out, int store_every, long max_bounces_per_iter)
{
    double *a = (double *)malloc(sizeof(double) * n);
    double *b = (double *)malloc(sizeof(double) * n);
    long total = 0;
    int stored = 0;
    for (int it = 0; it < iters; it++) {
        memcpy(a, z, sizeof(double) * n);
        memcpy(b, W + (long)it * n, sizeof(double) * n);
        double trem = T;
        long nb = 0;
        for (;;) {
            /* first wall hit: t*_i = atan2(b_i, a_i) + pi/2, monotone in b_i / r_i for a_i >= 0 */
            int jmin = -1;
            double kmin = 2.0;
            for (int i = 0; i < n; i++) {
                double r = sqrt(a[i] * a[i] + b[i] * b[i]);
                if (r <= 0.0) continue;
                double key = b[i] / r;
                if (a[i] < 0.0 && b[i] < 0.0) key = -1.0 - 1e-300; /* already outside, leaving */
                if (key < kmin) { kmin = key; jmin = i; }
            }
            double th = 1e300;
            if (jmin >= 0) {
                if (a[jmin] < 0.0 && b[jmin] < 0.0) th = 0.0;
                else th = atan2(b[jmin], a[jmin]) + M_PI / 2.0;
            }
            if (jmin < 0 || th >= trem || nb >= max_bounces_per_iter) {
                double c = cos(trem), s = sin(trem);
                for (int i = 0; i < n; i++) z[i] = a[i] * c + b[i] * s;
                break;
            }
            double c = cos(th), s = sin(th);
            for (int i = 0; i < n; i++) {
                double zi = a[i] * c + b[i] * s;
                double wi = -a[i] * s + b[i] * c;
                a[i] = zi; b[i] = wi;
            }
            a[jmin] = 0.0;
            double coef = 2.0 * b[jmin] / Sigma[(long)jmin * n + jmin];
            const double *col = Sigma + (long)jmin * n; /* symmetric: row == column */
            for (int i = 0; i < n; i++) b[i] -= coef * col[i];
            trem -= th;
            nb++;
        }
        /* clip roundoff: the exact dynamics never leaves the closed orthant */
        for (int i = 0; i < n; i++) if (z[i] < 0.0) z[i] = 0.0;
        total += nb;
        if ((it + 1) % store_every == 0) {
            memcpy(out + (long)stored * n, z, sizeof(double) * n);
            stored++;
        }
    }
    free(a); free(b);
    return total;
}
