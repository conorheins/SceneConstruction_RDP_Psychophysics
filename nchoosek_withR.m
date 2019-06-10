function [ numCombos ] = nchoosek_withR( N,K )
%nchoosek_withR It's like MATLAB's native nchoosek but with replacements

numCombos = prod(1:(N + K - 1)) / (prod(1:K) * prod(1:(N-1)));


end

