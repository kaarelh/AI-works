// Exact finite-cube summation algorithm in floating-point arithmetic.
// Meet in the middle reduces a ReLU Fourier coefficient from O(2^r)
// evaluations to O(r 2^(r/2)) sorting and a linear sweep.
// Outputs coefficients for targets omitting the first 0, 2, and 4 bits.
// Numerical diagnostics only: no interval-arithmetic certificate.
#include <algorithm>
#include <array>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <random>
#include <stdexcept>
#include <string>
#include <vector>

struct Entry { double sum; uint32_t mask; };
std::vector<Entry> subset_sums(const std::vector<double>& w, int first, int n) {
  if(n>24) throw std::runtime_error("half-cube exceeds memory budget");
  uint32_t count=uint32_t(1)<<n;
  std::vector<Entry> a(count);
  double total=0; for(int i=0;i<n;i++) total+=w[first+i];
  a[0]={-total,0};
  for(uint32_t m=1;m<count;m++) {
    int bit=__builtin_ctz(m); uint32_t rest=m&(m-1);
    a[m]={a[rest].sum+2*w[first+bit],m};
  }
  std::sort(a.begin(),a.end(),[](const Entry& x,const Entry& y){return x.sum<y.sum;});
  return a;
}
int sign(uint32_t mask,int n) { return ((n-__builtin_popcount(mask))&1)?-1:1; }
std::array<double,3> coefficients(const std::vector<double>& w) {
  int r=w.size(),left=r/2,right=r-left;
  if(left<4) throw std::runtime_error("need at least eight coordinates");
  auto a=subset_sums(w,0,left),b=subset_sums(w,left,right);
  int64_t cursor=b.size()-1,count=0;
  long double weighted=0,totals[3]={0,0,0},correction[3]={0,0,0};
  for(const auto& x:a) {
    while(cursor>=0 && b[cursor].sum>-x.sum) {
      int s=sign(b[cursor].mask,right);count+=s;
      weighted+=(long double)s*b[cursor].sum;--cursor;
    }
    long double term=((long double)x.sum*count+weighted)*sign(x.mask,left);
    for(int k=0;k<3;k++) {
      int modifier=(__builtin_popcount(x.mask&((uint32_t(1)<<(2*k))-1))&1)?-1:1;
      long double next=term*modifier-correction[k],updated=totals[k]+next;
      correction[k]=(updated-totals[k])-next;totals[k]=updated;
    }
  }
  std::array<double,3> out;
  for(int k=0;k<3;k++) out[k]=std::ldexp((double)totals[k],-r);
  return out;
}
std::array<double,3> brute(const std::vector<double>& w) {
  int r=w.size(); if(r>22)throw std::runtime_error("brute cube too large");
  long double totals[3]={0,0,0};
  for(uint32_t mask=0;mask<(uint32_t(1)<<r);mask++) {
    long double z=0;for(int i=0;i<r;i++)z+=((mask>>i)&1)?w[i]:-w[i];
    if(z<=0)continue;
    for(int k=0;k<3;k++)totals[k]+=sign(mask>>(2*k),r-2*k)*z;
  }
  std::array<double,3> out;for(int k=0;k<3;k++)out[k]=std::ldexp((double)totals[k],-r);
  return out;
}
int main(int argc,char** argv) {
  if(argc!=6 && argc!=7) {std::cerr<<"r A samples seed output.jsonl [gaussian|uniform|laplace]\n";return 2;}
  std::string noise=argc==7?argv[6]:"gaussian";
  if(noise!="gaussian"&&noise!="uniform"&&noise!="laplace")throw std::runtime_error("invalid noise law");
  int r=std::stoi(argv[1]),samples=std::stoi(argv[3]);
  double A=std::stod(argv[2]),sigma=std::sqrt(A*std::log(double(r))/r);
  std::mt19937_64 rng(std::stoull(argv[4]));std::normal_distribution<double> normal;
  std::ofstream out(argv[5]);if(!out)throw std::runtime_error("output open failed");
  out<<std::setprecision(17);
  auto start=std::chrono::steady_clock::now();
  std::array<long double,3> first{},second{},fourth{},hermite{},product_second{};
  double maximum_brute_difference=0;
  for(int draw=0;draw<samples;draw++) {
    std::vector<double> w(r),z(r);
    for(int i=0;i<r;i++){
      if(noise=="gaussian")z[i]=normal(rng);
      else {
        double u=(double(rng()>>11)+.5)*0x1.0p-53;
        if(noise=="uniform")z[i]=std::sqrt(3.)*(2*u-1);
        else z[i]=(u<.5?std::log(2*u):-std::log(2*(1-u)))/std::sqrt(2.);
      }
      w[i]=1+sigma*z[i];
    }
    auto g=coefficients(w);
    if(r<=20&&draw<10) {
      auto direct=brute(w);
      for(int k=0;k<3;k++) {
        double err=std::abs(g[k]-direct[k]);maximum_brute_difference=std::max(maximum_brute_difference,err);
        if(err>1e-10)throw std::runtime_error("brute coefficient mismatch");
      }
    }
    double prod=1;
    for(int k=0;k<3;k++) {
      if(k)prod*=z[2*k-2]*z[2*k-1];
      first[k]+=g[k];second[k]+=(long double)g[k]*g[k];
      fourth[k]+=(long double)g[k]*g[k]*g[k]*g[k];hermite[k]+=prod*g[k];product_second[k]+=(long double)prod*prod*g[k]*g[k];
    }
    if((draw+1)%25==0||draw+1==samples) {
      double sec=std::chrono::duration<double>(std::chrono::steady_clock::now()-start).count();
      out<<"{\"noise\":\""<<noise<<"\",\"r\":"<<r<<",\"A\":"<<A<<",\"sigma\":"<<sigma<<",\"samples\":"<<draw+1<<",\"seconds\":"<<sec<<",\"maximum_brute_difference\":"<<maximum_brute_difference<<",\"shells\":[";
      for(int k=0;k<3;k++) {
        double n=draw+1,m=double(second[k]/n),se=std::sqrt(std::max(0.,double(fourth[k]/n)-m*m)/n);
        if(k)out<<',';
        out<<"{\"omitted\":"<<2*k<<",\"mean_coefficient\":"<<double(first[k]/n)<<",\"kernel_estimate\":"<<m<<",\"kernel_standard_error\":"<<se<<",\"hermite_alignment\":"<<double(hermite[k]/n)<<",\"product_alignment_standard_error\":"<<std::sqrt(std::max(0.,double(product_second[k]/n)-std::pow(double(hermite[k]/n),2))/n)<<'}';
      }
      out<<"]}\n";out.flush();
    }
  }
}
