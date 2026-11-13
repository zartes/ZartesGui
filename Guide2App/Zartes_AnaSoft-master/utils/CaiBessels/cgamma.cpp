// This subroutine calculates gamma function with a complex argument,
// usseful 4 calculating bessel function of complex order and complex argument.
// mex cgamma.cpp --> cgamma.dll, which can be used in MATLAB as a built-in function,
// tested using Visual C++ 6.0 (mex -setup in MATLAB)
// The calculating results of this subroutine agrees perfectly with MATHEMAICA
// In MATLAB: y = cgamma(nu, x), where nu is a complex number or a one-row complex vector. 
// For real nu, please use MATLAN function gamma.
//  --------   By Hongxue Cai, 09/29/2004   ----------

#include <iostream>
#include <cmath>
#include <complex>
#include "mex.h"

using namespace std;

void cgamma(double *Ry, double *Iy, double *Rx, double *Ix, int n)
{
    int j, k;
    static double a[] = {
            1.000000000190015,
            76.18009172947146,
            -86.50532032941677,
            24.01409824083091,
            -1.231739572450155,
            1.208650973866179e-3,
            -5.395239384953e-6
    };
    double PI = 3.14159265358979, dA = sqrt(2.0*PI);
    complex<double> A (dA, 0.0), y, z;
    
    for (k=0; k<n; k++){
        complex<double> x (Rx[k], Ix[k]);
	
        z = x;
        if (Rx(k) < 0.0)
            z = -x;
        
        complex<double> tem (0.0, 0.0);
        for (j = 1; j <= 6; j++)
            tem = tem + a[j]/(z + (double)j);

        y = A*(a[0] + tem)*pow((z+5.5),(z+0.5))*exp(-z-5.5)/z;

        if (real(x) < 0.0)
            y = -PI/(z*y*sin(PI*z));

        Ry[k] = real(y);
        Iy[k] = imag(y);
    }
    return;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
                 const mxArray *prhs[])
{
  double  *xr, *xi, *yr, *yi;
  int     rows, cols;
    
  // Check for the proper number of arguments. 
  if (nrhs != 1)
    mexErrMsgTxt("One input required.");
  if (nlhs > 1)
    mexErrMsgTxt("Too many output arguments.");

  // Check that both inputs are row vectors. 
  if (mxGetM(prhs[0]) != 1)
    mexErrMsgTxt("Input must be row vector.");
  rows = 1; 

  // Check that both inputs are complex. 
  if (!mxIsComplex(prhs[0]))
    mexErrMsgTxt("Input must be complex.\n");
  
  // Get the length of each input vector. 
  cols = mxGetN(prhs[0]);

  
  plhs[0] = mxCreateDoubleMatrix(rows, cols, mxCOMPLEX);

  // Get pointers to real and imaginary parts of the inputs.
  xr = mxGetPr(prhs[0]);
  xi = mxGetPi(prhs[0]);
  yr = mxGetPr(plhs[0]);
  yi = mxGetPi(plhs[0]);

  // call the c++ computational subroutine
  cgamma(yr, yi, xr, xi, cols);
  return;
}
