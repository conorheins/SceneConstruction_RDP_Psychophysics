 function [ output ] = nchoosek_withR( N,K )
%nchoosek_withR It's like MATLAB's native nchoosek but with replacements

if numel(N) > 1
    numCombos = prod(1:(length(N) + K - 1)) / (prod(1:K) * prod(1:(length(N)-1)));
    output = zeros(numCombos,K);
    
    counter = 1;
    for ii = 1:length(N)
        n_i = N(ii);
        for jj = ii:length(N)
            n_j = N(jj);           
            output(counter,:) = [n_i n_j];
            counter = counter + 1;
        end
    end
        
elseif numel(N) == 1
    output = prod(1:(N + K - 1)) / (prod(1:K) * prod(1:(N-1)));
end


end

