# A width-only approximation guarantee on Boolean inputs

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Independent mathematical reviews](verification/)

A fixed Bayesian ReLU network with independent Gaussian weights can approach the best squared risk of arbitrary-weight narrow ReLU teachers on Boolean inputs. Labels may have any bounded noise, and the input distribution is arbitrary. The comparison does not require a coefficient bound or a prior over network sizes.

The learner uses a fixed bounded final activation in both its Gaussian likelihood and its ordinary posterior-mean prediction. One positive likelihood variance is chosen from the data using two risk certificates. Its hidden depth must be at least a numerical constant times the teacher depth plus one. The guarantee holds at every learner width at least the teacher width plus the constant wire used to implement biases.

At fixed depths, the sample bound is polynomial in teacher width, input dimension, and inverse accuracy. The coefficient-free compiler costs only logarithmically in inverse accuracy. The resulting accuracy powers are:

| Prior | Positive comparison risk | Zero comparison risk |
|---|---:|---:|
| Independent Gaussian, gamma >= 2 | epsilon^(-(H+1)) | epsilon^-1 |
| Independent Gaussian, all gamma >= 1 | epsilon^(-(2H^2+H-1)) | epsilon^(-2H) |
| Full-support Gaussian prior with a soft gain penalty | epsilon^-2 | epsilon^-1 |

Here H is learner hidden depth. The last row changes the prior explicitly; it is not a claim for unchanged independent Gaussian coordinates. All rows suppress logarithmic factors and teacher-resource polynomials. A smooth final tanh variant has the same polynomials when the comparison class also uses final tanh.

The compiler's depth strengthening imports the standard constant-depth threshold-arithmetic theorem of Hesse, Allender, and Barrington. It is an existential, nonuniform construction. No efficient posterior computation or compiler extraction is claimed.

The Gaussian statistical certificates are imported from the companion adaptive-oracle and direct-compression results, with their exact hypotheses stated in the paper. The path-flow implementation, selective Gaussian comparison, all-width certificate selection, and coefficient-free Boolean compiler are proved here. The verification records distinguish independent conventional mathematical reviews from those imported results. This manuscript has not been Lean formalized.

Run `bash build.sh` to rebuild the PDF. Sources and verification snapshots are included.
