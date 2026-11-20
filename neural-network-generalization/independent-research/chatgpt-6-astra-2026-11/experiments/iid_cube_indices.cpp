#include <iostream>
#include <random>
#include <vector>
// Reproduces the data generator in parity_relu_cold_transfer.cpp.
int main(int argc,char**argv){
 if(argc!=4)return 2;
 size_t m=std::stoull(argv[1]);int n=std::stoi(argv[2]);
 std::mt19937_64 rng(std::stoull(argv[3]));std::vector<int> counts(m,0);
 for(int i=0;i<n;i++)counts[std::uniform_int_distribution<size_t>(0,m-1)(rng)]++;
 std::cout<<'[';for(size_t j=0;j<m;j++){if(j)std::cout<<',';std::cout<<counts[j];}std::cout<<"]\n";
}
