// Coordinate Gibbs with explicit isotropic / fan-in / small Gaussian priors.
// Generated from parity_softplus_gibbs.cpp; readout and incoming scales differ.
// Conditionals are exact truncated Gaussians; mixing is not certified.
#include <algorithm>
#include <chrono>
#include <cmath>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <numeric>
#include <random>
#include <set>
#include <stdexcept>
#include <string>
#include <vector>
const double INF=std::numeric_limits<double>::infinity();
double sp(double x){return std::max(x,0.)+std::log1p(std::exp(-std::abs(x)));}
double isp(double x){return x+std::log(-std::expm1(-x));}
struct RNG{
 std::mt19937_64 gen;std::normal_distribution<double> norm;
 RNG(int s):gen(s),norm(0,1){}
 double u(){return (double(gen()>>11)+.5)*0x1.0p-53;}
 double trunc(double l,double h){
  if(!(l<h))throw std::runtime_error("empty interval");
  if(h<=0)return -trunc(-h,-l);
  if(l>=0){double alpha=(l+std::hypot(l,2.))/2;
   double mass=std::isinf(h)?1.:-std::expm1(-alpha*(h-l));
   for(;;){double z=l-std::log1p(-u()*mass)/alpha;
    if(z<h&&std::log(u())<=-.5*(z-alpha)*(z-alpha))return z;}}
  if(h-l<1.5){for(;;){double z=l+(h-l)*u();if(std::log(u())<=-.5*z*z)return z;}}
  for(;;){double z=norm(gen);if(z>l&&z<h)return z;}
 }
};
struct Chain{
 int d,n,m,k,seed,D;double tau,sa,s;std::string mode,profile;RNG rng;
 std::vector<double> theta,X,y,total,pre,rest,tmp;
 Chain(int dim,int width,int sd,std::string init,double margin,std::string prior):
  d(dim),n(width),m(1<<d),k(m/2),seed(sd),D(d+2),tau(prior=="isotropic"?1:1/std::sqrt(double(d))),sa(prior=="small"?1/std::sqrt(double(d)):1),s(margin),mode(init),profile(prior),rng(sd),
  theta(n*D,0),X(m*(d+1),1),y(m,1),total(m,0),pre(m),rest(m),tmp(m){
  if(d<4||d%2||n<k||n%k)throw std::runtime_error("even d>=4 and width multiple of 2^(d-1) required");
  for(int x=0;x<m;x++)for(int i=0;i<d;i++){X[x*(d+1)+1+i]=(x>>i&1)?1:-1;y[x]*=X[x*(d+1)+1+i];}
  int reserve=mode=="condensed"?k:n;
  for(int j=reserve;j<n;j++)for(int q=0;q<D;q++)theta[j*D+q]=(q==0?sa:tau)*rng.norm(rng.gen);
  double R=.1,sign=((d/2-1)%2)?-1:1;
  for(;;){
   for(int j=0;j<reserve;j++){int x=2*(j%k)+1;double *v=&theta[j*D];v[0]=sa*sign*y[x]*R;v[1]=0;
    for(int i=0;i<d;i++)v[2+i]=tau*R*X[x*(d+1)+1+i]/std::sqrt(double(d));}
   recompute();double low=INF;for(int x=0;x<m;x++)low=std::min(low,y[x]*total[x]/n);
   if(low>s+.05)break;R*=1.025;
  }
 }
 void neuron(const double *v,std::vector<double>&out){
  for(int x=0;x<m;x++){double z=0;for(int q=1;q<D;q++)z+=v[q]*X[x*(d+1)+q-1];out[x]=v[0]*sp(z);}
 }
 void recompute(){std::fill(total.begin(),total.end(),0.);for(int j=0;j<n;j++){neuron(&theta[j*D],tmp);for(int x=0;x<m;x++)total[x]+=tmp[x];}}
 void update(int j){
  double *v=&theta[j*D];double lo=-INF,hi=INF;
  for(int x=0;x<m;x++){
   double z=0;for(int q=1;q<D;q++)z+=v[q]*X[x*(d+1)+q-1];pre[x]=z;double phi=sp(z);rest[x]=total[x]-v[0]*phi;
   double b=(y[x]*n*s-rest[x])/phi;if(y[x]>0)lo=std::max(lo,b);else hi=std::min(hi,b);
  }
  v[0]=sa*rng.trunc(lo/sa,hi/sa);
  for(int q=1;q<D;q++){
   lo=-INF;hi=INF;double old=v[q];
   for(int x=0;x<m;x++){
    double A=y[x]*v[0],value=(n*s-y[x]*rest[x])/A;
    if(A>0&&value<=0)continue;
    if(value<=0)throw std::runtime_error("infeasible coordinate");
    double xq=X[x*(d+1)+q-1],b=(isp(value)-pre[x]+old*xq)/xq;
    if(A*xq>0)lo=std::max(lo,b);else hi=std::min(hi,b);
   }
   v[q]=tau*rng.trunc(lo/tau,hi/tau);double change=v[q]-old;
   for(int x=0;x<m;x++)pre[x]+=change*X[x*(d+1)+q-1];
  }
  for(int x=0;x<m;x++)total[x]=rest[x]+v[0]*sp(pre[x]);
 }
 void sweep(){for(int j=0;j<n;j++)update(int(rng.gen()%n));}
 void record(std::ostream&out,long sweep,double sec){
  recompute();double low=INF,high=-INF,energy=0;
  for(int x=0;x<m;x++){low=std::min(low,y[x]*total[x]/n);high=std::max(high,y[x]*total[x]/n);}
  if(low<s-1e-8)throw std::runtime_error("margin violated");
  std::vector<std::pair<double,int>> order;
  for(int j=0;j<n;j++){double e=0;for(int q=0;q<D;q++)e+=theta[j*D+q]*theta[j*D+q];energy+=e;order.push_back({e,j});}
  std::sort(order.rbegin(),order.rend());std::vector<double> bulk=total;std::set<int> orientations;int aligned=0;
  double sig=((d/2-1)%2)?-1:1;
  for(int a=0;a<k;a++){
   auto *v=&theta[order[a].second*D];neuron(v,tmp);for(int x=0;x<m;x++)bulk[x]-=tmp[x];
   int orient=0;double chi=1;for(int i=0;i<d;i++){if(v[i+2]>0)orient|=1<<i;else chi=-chi;}
   orientations.insert(orient);if(v[0]*sig*chi>0)aligned++;
  }
  double bm=0,br=0;for(int x=0;x<m;x++){bm+=y[x]*bulk[x]/(n*m);br+=bulk[x]*bulk[x]/(double(n)*n*m);}
  out<<std::setprecision(15)<<"{\"prior\":\""<<profile<<"\",\"readout_std\":"<<sa<<",\"incoming_std\":"<<tau<<",\"dimension\":"<<d<<",\"width\":"<<n<<",\"seed\":"<<seed<<",\"initialization\":\""<<mode<<"\",\"sweep\":"<<sweep<<",\"seconds\":"<<sec<<",\"min_margin\":"<<low<<",\"max_margin\":"<<high<<",\"energy_per_neuron\":"<<energy/n<<",\"bulk_parity\":"<<bm<<",\"bulk_rms\":"<<std::sqrt(br)<<",\"top_orientation_count\":"<<orientations.size()<<",\"top_readout_alignment_count\":"<<aligned<<",\"top_scaled_norms\":[";
  for(int a=0;a<std::min(n,k+8);a++){if(a)out<<',';out<<std::sqrt(order[a].first/n);}out<<"]}\n";out.flush();
 }
};
int main(int argc,char**argv){
 if(argc<8){std::cerr<<"dimension width seed initialization sweeps record_every output [margin] [prior: isotropic/fan-in/small]\n";return 2;}
 int d=std::stoi(argv[1]),n=std::stoi(argv[2]),seed=std::stoi(argv[3]);std::string mode=argv[4];long sweeps=std::stol(argv[5]),every=std::stol(argv[6]);double s=argc>8?std::stod(argv[8]):.5;
 auto start=std::chrono::steady_clock::now();std::string prior=argc>9?argv[9]:"isotropic";if(prior!="isotropic"&&prior!="fan-in"&&prior!="small")throw std::runtime_error("invalid prior");Chain c(d,n,seed,mode,s,prior);std::ofstream out(argv[7]);
 for(long j=0;j<=sweeps;j++){
  if(j%every==0){double sec=std::chrono::duration<double>(std::chrono::steady_clock::now()-start).count();c.record(out,j,sec);if(j%(100*every)==0)std::cout<<"sweep "<<j<<" seconds "<<sec<<std::endl;}
  if(j<sweeps)c.sweep();
 }
}
