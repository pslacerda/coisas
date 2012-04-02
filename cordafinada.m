% Cordafinada.m
%
% Cordafinada é um instrumento musical que sabe ler partituras. Sintetiza o
% som emitido por cordas.
%
% Autor: Pedro Sousa Lacerda, 2010
%
% UFBA - Bacharelado Interdisciplinar em Ciência e Tecnologia
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Escrevendo Partituras
%
%   Somente uma nota e duração é
%   analisada por vez.
%   
%   Primeira linha de partitura contém notas, iniciando em Lá (A na notação
%   de Helmholtz; A2 na notação científica). Na segunda há sua duração,
%   medida em frações da unidade de tempo ut em segundos.
%

% Melodia 1) Speed the Plought
ut = .4;        %unidade de tempo
partitura = []; %notas e duração

partitura = [partitura [12 13 14 15 16 17 16 14    16 17 16 14 16 17 16 14    15 17 15 14 16 14    15 13 13 14 13;
                        .5 .5 .5 .5 .5 .5 .5 .5    .5 .5 .5 .5 .5 .5 .5 .5    1  .5 .5 1  .5 .5    1  1  1  .5 .5]];
                    
partitura = [partitura [12 13 14 15 16 17 16 14    16 17 16 14 16 17 16 14    15 17 15 14 16 14    13 11 12;
                        .5 .5 .5 .5 .5 .5 .5 .5    .5 .5 .5 .5 .5 .5 .5 .5    1  .5 .5 1  .5 .5    1  1  2]];
                    
partitura = [partitura [19 19 18 19 16 12 16       19 18 17 16                15 17 15 14 17 14    15 13 13 16 18;
                        1  .5 .5 .5 .5 .5 .5       1  1  1  1                 1  .5 .5 1  .5 .5    1  1  1  .5 .5]];
                    
partitura = [partitura [19 19 18 19 14 16          19 18 17 16                15 17 15 16 18 16    13 11 12;
                        1  .5 .5 1  .5 .5          1  1  1  1                 1  .5 .5 1  .5 .5    1  1  2]];


% Melodia 2) Uma Corda Só
%ut = 2;
%partitura = [20; 1];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Início do Programa
%
Fa = 44100; %taxa de amostragem
Ta = 1/Fa;  %tempo da amostra

musica = [];
for p=partitura   %para cada coluna da partitura
    
    % Tempo de duração da nota atual (coluna atual).
    t = 0:Ta:p(2)*ut;
    
    %   A frequência de uma nota é a de sua antecessora vezes 2^(1/12)
    %
    %       n1 = n0 * 2^(1/12)
    %   
    %   Uma vibração de 440hz é conhecida como a nota Lá440, geralmente é
    %   usada como referência para afinar instrumentos musicais. Na
    %   Wikipedia encontra-se a seguinte função para descobrir a frequência
    %   da corda n de uma piano, assumindo que o Lá440 é a 49a corda:
    %
    %       f(n) = 440 * 2^(1/12) ^ (n-49)
    %
    %   Modificamos a função para atender o Cordafinada, nosso
    %   instrumento. Sua primeira corda é Lá (A na notação de Helmholtz;
    %   A2 na scientific notation).
    %       
    %       f(n) = 110 * 2^(1/12) ^ n
    %
    f = 110 * 2^(1/12) ^ p(1);
    
    
    %   Uma vez encontrada a frequência, modulamos a nota em uma onda. Para
    %   isso utilizamos uma transformada discreta de Fourier, que deixa o
    %   formato da onda parecido com o que cordas emitem.
    %
    %       sin(x) + sin(x*2)/2 + sin(x*4)/4
    %
    %   Obtido em: <http://www.frontiernet.net/~imaging/play_a_piano.html>.
    %   O site saiu do ar há poucos dias, mas existem muitas citações à
    %   ele ainda.
    %
    nota = sin(f*t*2*pi) + sin(f*t*2*pi*2)/2 + sin(f*t*2*pi*4)/4;
    
    %   Envelopa onda simulando seu comportamento. A duração do envelope é
    %   limitada pela duração da nota. Contém apenas decaimento, mas ainda
    %   assim se assemelha ao envelope de uma corda real.
    %    
    env = 0:Ta:3;               %duração do envelope (sem limite da nota) e
    env = env*1-exp(env/3);     %   seu decaimento exponencial.
    
    to = size(nota);to=to(2);   %limita duração do envelope à duração da
    env = env(1:to);            %   nota.
    
    nota = nota.*env; %aplica o envelope à nota.
    
    % Acrescenta nota modulada à variável para reprodução. Concatena a
    % música que já foi produzida com a nota recém modulada.
    %
    musica = horzcat(musica,nota);
end

% Toca Raul!
sound(musica, Fa);
