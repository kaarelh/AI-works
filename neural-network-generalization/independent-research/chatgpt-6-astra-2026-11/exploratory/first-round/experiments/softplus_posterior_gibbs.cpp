// Exact coordinate conditionals for the four-margin Gaussian softplus posterior.
// This is an MCMC diagnostic, not a mixing-time certificate.
#include <algorithm>
#include <array>
#include <chrono>
#include <cmath>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <numeric>
#include <random>
#include <stdexcept>
#include <string>
#include <vector>
using V=std::array<double,4>;
const double INF=std::numeric_limits<double>::infinity();
const double X[4][3]={{1,-1,-1},{1,-1,1},{1,1,-1},{1,1,1}};
const double Y[4]={1,-1,-1,1};
double sp(double x){return std::max(x,0.)+std::log1p(std::exp(-std::abs(x)));}
double invsp(double x){return x+std::log(-std::expm1(-x));}
struct RNG{
 std::mt19937_64 gen;std::normal_distribution<double> norm;
 RNG(int seed):gen(seed),norm(0,1){}
 double u(){return (double(gen()>>11)+.5)*0x1.0p-53;}
 double normal(){return norm(gen);}
 double trunc(double l,double h){
  if(!(l<h))throw std::runtime_error("empty normal interval");
  if(h<=0)return -trunc(-h,-l);
  if(l>=0){
   double alpha=(l+std::hypot(l,2.))/2;
   double mass=std::isinf(h)?1.:-std::expm1(-alpha*(h-l));
   for(;;){double z=l-std::log1p(-u()*mass)/alpha;
    if(z>=h)continue;
    if(std::log(u())<=-.5*(z-alpha)*(z-alpha))return z;}
  }
  if(h-l<1.5){for(;;){double z=l+(h-l)*u();if(std::log(u())<=-.5*z*z)return z;}}
  for(;;){double z=normal();if(z>l&&z<h)return z;}
 }
};
struct Chain{
 int n,seed;double s;std::string init;RNG rng;std::vector<V> theta;V total{};
 Chain(int N,double margin,int sd,std::string mode):n(N),seed(sd),s(margin),init(mode),rng(sd),theta(N){
  if(init=="condensed"){
   for(int j=4;j<n;j++)for(int k=0;k<4;k++)theta[j][k]=rng.normal();
   recompute();
   double R=1.;for(;;){
    for(int j=0;j<4;j++)theta[j]={Y[j]*R,0,X[j][1]*R/std::sqrt(2.),X[j][2]*R/std::sqrt(2.)};
    recompute();if(min_margin()>s+.1)break;R*=1.02;
   }
  }else{
   if(n%4)throw std::runtime_error("democratic initialization needs width multiple of four");
   double R=1.;for(;;){
    for(int j=0;j<n;j++){int k=j%4;theta[j]={Y[k]*R,0,X[k][1]*R/std::sqrt(2.),X[k][2]*R/std::sqrt(2.)};}
    recompute();if(min_margin()>s+.1)break;R*=1.02;
   }
  }
 }
 V output(const V &v){V out{};for(int x=0;x<4;x++)out[x]=v[0]*sp(v[1]+v[2]*X[x][1]+v[3]*X[x][2]);return out;}
 void recompute(){total={};for(const auto &v:theta){V f=output(v);for(int x=0;x<4;x++)total[x]+=f[x];}}
 double min_margin(){double m=INF;for(int x=0;x<4;x++)m=std::min(m,Y[x]*total[x]/n);return m;}
 void update(int j){
  V &v=theta[j],old=output(v),rest;
  for(int x=0;x<4;x++)rest[x]=total[x]-old[x];
  double l=-INF,h=INF;
  for(int x=0;x<4;x++){
   double phi=sp(v[1]+v[2]*X[x][1]+v[3]*X[x][2]);
   double b=(Y[x]*n*s-rest[x])/phi;
   if(Y[x]>0)l=std::max(l,b);else h=std::min(h,b);
  }
  v[0]=rng.trunc(l,h);
  for(int k=1;k<4;k++){
   l=-INF;h=INF;
   for(int x=0;x<4;x++){
    double A=Y[x]*v[0],rhs=n*s-Y[x]*rest[x],value=rhs/A;
    if(A>0&&value<=0)continue;
    if(value<=0)throw std::runtime_error("infeasible incoming conditional");
    double c=0;for(int q=1;q<4;q++)if(q!=k)c+=v[q]*X[x][q-1];
    double bound=(invsp(value)-c)/X[x][k-1];
    if(A*X[x][k-1]>0)l=std::max(l,bound);else h=std::min(h,bound);
   }
   v[k]=rng.trunc(l,h);
  }
  V f=output(v);for(int x=0;x<4;x++)total[x]=rest[x]+f[x];
 }
 void sweep(){
  // A random scan has N independent uniformly chosen neuron blocks.
  for(int k=0;k<n;k++)update(int(rng.gen()%n));
 }
 void record(std::ostream &out,long sweep,double seconds){
  recompute();if(min_margin()<s-1e-9)throw std::runtime_error("margin violated");
  std::vector<std::pair<double,int>> order;
  double energy=0,bias2=0;
  for(int j=0;j<n;j++){double e=std::inner_product(theta[j].begin(),theta[j].end(),theta[j].begin(),0.);energy+=e;bias2+=theta[j][1]*theta[j][1];order.push_back({e,j});}
  std::sort(order.rbegin(),order.rend());V big{};
  for(int k=0;k<4;k++){V f=output(theta[order[k].second]);for(int x=0;x<4;x++)big[x]+=f[x];}
  out<<std::setprecision(16)<<"{\"width\":"<<n<<",\"seed\":"<<seed<<",\"initialization\":\""<<init<<"\",\"sweep\":"<<sweep<<",\"seconds\":"<<seconds<<",\"energy_per_neuron\":"<<energy/n<<",\"bias2_per_neuron\":"<<bias2/n<<",\"margin\":[";
  for(int x=0;x<4;x++){if(x)out<<',';out<<Y[x]*total[x]/n;}out<<"],\"bulk_margin\":[";
  for(int x=0;x<4;x++){if(x)out<<',';out<<Y[x]*(total[x]-big[x])/n;}out<<"],\"top_scaled_norms\":[";
  for(int k=0;k<std::min(n,12);k++){if(k)out<<',';out<<std::sqrt(order[k].first/n);}out<<"],\"top_parameters\":[";
  for(int k=0;k<std::min(n,8);k++){if(k)out<<',';out<<'[';auto &v=theta[order[k].second];for(int q=0;q<4;q++){if(q)out<<',';out<<v[q]/std::sqrt(n);}out<<']';}
  out<<"]}\n";out.flush();
 }
};
int main(int argc,char**argv){
 if(argc<7){std::cerr<<"width seed initialization sweeps record_every output [margin]\n";return 2;}
 int n=std::stoi(argv[1]),seed=std::stoi(argv[2]);std::string init=argv[3];long sweeps=std::stol(argv[4]),every=std::stol(argv[5]);double s=argc>7?std::stod(argv[7]):.5;
 auto start=std::chrono::steady_clock::now();Chain c(n,s,seed,init);std::ofstream out(argv[6]);
 for(long k=0;k<=sweeps;k++){
  if(k%every==0){double sec=std::chrono::duration<double>(std::chrono::steady_clock::now()-start).count();c.record(out,k,sec);if(k%(every*100)==0)std::cout<<"sweep "<<k<<" seconds "<<sec<<std::endl;}
  if(k<sweeps)c.sweep();
 }
}
