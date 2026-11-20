// Parallel tempering for ONE ordinary neuron under Q_t ∝ exp(t a G) P_4.
// Fold incoming signs using parity symmetry; b is folded by even-degree symmetry.
// Metropolis kernels and swaps preserve the stated law. Mixing is not certified.
#include <algorithm>
#include <array>
#include <chrono>
#include <cmath>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <random>
#include <vector>
struct State {std::vector<double> v,pre;double G=0,V=0,step=.3;long accepted=0,proposed=0;};
int main(int argc,char**argv){
 int d=argc>1?std::stoi(argv[1]):6,seed=argc>2?std::stoi(argv[2]):0;
 long sweeps=argc>3?std::stol(argv[3]):200000;double tmax=argc>4?std::stod(argv[4]):80;
 int replicas=81,D=d+2,M=1<<d;double ell=std::sqrt(std::tgamma(.25)/std::tgamma(.75)),ell4=std::pow(ell,4);
 std::mt19937_64 rng(seed);std::normal_distribution<double> normal;auto uni=[&](){return (double(rng()>>11)+.5)*0x1.0p-53;};
 std::vector<std::vector<double>> X(M,std::vector<double>(d+1,1));std::vector<double> y(M,1),ts(replicas);
 for(int x=0;x<M;x++)for(int j=0;j<d;j++){X[x][j+1]=(x>>j&1)?1:-1;y[x]*=X[x][j+1];}
 std::vector<State> st(replicas);std::vector<std::array<double,8>> sum(replicas),sum2(replicas);long count=0,swapacc=0,swapprop=0;
 auto energy=[&](double x){return x*x*x*x/ell4;};
 for(int k=0;k<replicas;k++){ts[k]=tmax*k/(replicas-1);auto &s=st[k];s.v.resize(D);s.pre.resize(M);for(int j=0;j<D;j++)s.v[j]=(j==0?normal(rng):std::abs(normal(rng)));for(double z:s.v)s.V+=energy(z);for(int x=0;x<M;x++){for(int j=1;j<D;j++)s.pre[x]+=s.v[j]*X[x][j-1];s.G+=y[x]*std::max(0.,s.pre[x])/M;}}
 std::ofstream dump;if(argc>5)dump.open(argv[5],std::ios::binary);int sample_index=std::min(replicas-1,int(std::round(29.0*(replicas-1)/tmax)));
 auto start=std::chrono::steady_clock::now();long burn=20000;
 for(long sw=1;sw<=sweeps;sw++){
  for(int k=0;k<replicas;k++){
   auto&s=st[k];for(int z=0;z<D;z++){
    int j=rng()%D;double old=s.v[j],next=old+s.step*normal(rng);if(j>0)next=std::abs(next);double change=next-old,newG=s.G;
    if(j>0){newG=0;for(int x=0;x<M;x++)newG+=y[x]*std::max(0.,s.pre[x]+change*X[x][j-1])/M;}
    double newa=j==0?next:s.v[0],dv=energy(next)-energy(old),lr=-dv+ts[k]*(newa*newG-s.v[0]*s.G);s.proposed++;
    if(std::log(uni())<lr){s.accepted++;s.v[j]=next;s.V+=dv;s.G=newG;if(j>0)for(int x=0;x<M;x++)s.pre[x]+=change*X[x][j-1];}
   }
   if(sw<5000&&sw%100==0){double a=double(s.accepted)/s.proposed;s.step*=std::exp(.3*(a-.35));s.step=std::clamp(s.step,.01,3.);s.accepted=s.proposed=0;}
  }
  for(int k=sw%2;k<replicas-1;k+=2){swapprop++;double lr=(ts[k+1]-ts[k])*(st[k].v[0]*st[k].G-st[k+1].v[0]*st[k+1].G);if(std::log(uni())<lr){std::swap(st[k],st[k+1]);swapacc++;}}
  if(sw>burn){count++;for(int k=0;k<replicas;k++){auto&s=st[k];double u2=0,up=0;for(int j=1;j<D;j++){u2+=s.v[j]*s.v[j];up+=energy(s.v[j]);}std::array<double,8>v{s.v[0]*s.G,s.G*s.G,s.v[0]*s.v[0],u2,energy(s.v[0]),up,s.v[1],s.step};for(int j=0;j<8;j++){sum[k][j]+=v[j];sum2[k][j]+=v[j]*v[j];}if(dump&&k==sample_index&&sw%10==0)dump.write(reinterpret_cast<const char*>(v.data()),6*sizeof(double));}}
  if(sw%10000==0){double sec=std::chrono::duration<double>(std::chrono::steady_clock::now()-start).count();for(int k=0;k<replicas;k++){std::cout<<std::setprecision(16)<<"{\"dimension\":"<<d<<",\"seed\":"<<seed<<",\"sweep\":"<<sw<<",\"samples\":"<<count<<",\"tilt\":"<<ts[k]<<",\"seconds\":"<<sec<<",\"swap_acceptance\":"<<double(swapacc)/swapprop;if(count){const char*names[]={"mean_parity","parity_kernel","readout_energy","incoming_energy","readout_p_energy","incoming_p_energy","bias_mean","step"};for(int j=0;j<8;j++)std::cout<<",\""<<names[j]<<"\":"<<sum[k][j]/count;}std::cout<<"}\n";}std::cout<<std::flush;}
 }
}
