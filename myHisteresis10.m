function [Y] = myHysteresis10(U)

%Inicialização Saída, Vetor de Diferenças, Vetor de Estados, Estado Inicial, Saída Inicial
Ganho = zeros(length(U),1);
delta = zeros(length(U),1);
Es = zeros(length(U),1);
Ud = zeros(length(U),1);

%Inicialização Coeficientes e Folga
A = 0.1039;
B = 0.2989;
C = 1.0459;
folga = 0.14;

%Inicialização 1 Termo
Estado = 1;
Es(1) = 1;
Ganho(1) = A*U(1)*U(1) - B*U(1) + C; %Curva Subida
h = 0;

%Interações para Cálculo da Saída e Estado da Válvula
for i=2:length(U)
    
    delta(i) = U(i) - U(i-1);
    Ud(i) = U(i) + folga;
    
    %Valores fora da faixa nominal
    if U(i) <= 1.9
        Ganho(i) = 0.87;
    
    elseif U(i) >= 4.2
        Ganho(i) = 1.6;
    
    %Valores na Faixa nominal
    else
            switch Estado
                
                %Estado - Mensurando Subindo
                case 1 
                    
                    if delta(i) >= 0 
                        %Estado - Mensurando Subindo
                        Estado = 1;
                        Es(i) = 1;
                        h = 0;
                        Ganho(i) = A*U(i)*U(i) - B*U(i) + C;
                        
                    elseif (delta(i) < 0 & delta(i) >= -folga)
                        %Estado - Folga na Subida
                        Estado = 2;
                        Es(i) = 2;
                        h = h + delta(i);
                        Ganho(i) = Ganho(i-1);
                                                
                    elseif delta(i) < -folga
                        %Estado - Mensurando Descendo
                        Estado = 3;
                        Es(i) = 3;
                        h = 0;
                        Ganho(i) = A*Ud(i)*Ud(i) - B*Ud(i) + C;

                    end
                
                %Estado - Folga na Subida
                case 2
                                        
                    if (delta(i) + h) > 0
                        %Estado - Mensurando Subindo
                        Estado = 1;
                        Es(i) = 1;
                        h = 0;
                        Ganho(i) = A*U(i)*U(i) - B*U(i) + C;
                                                                       
                    elseif ((delta(i) + h) <= 0 & (delta(i) + h) >= -folga) 
                        %Estado - Folga na Subida
                        Estado = 2;
                        Es(i) = 2;
                        h = h + delta(i);
                        Ganho(i) = Ganho(i-1);
                        
                    elseif (delta(i) + h) < -folga
                        %Estado - Mensurando Descendo
                        Estado = 3;
                        Es(i) = 3;
                        h = 0;
                        Ganho(i) = A*Ud(i)*Ud(i) - B*Ud(i) + C;
                 end
                    
                    
                %Estado - Mensurando Descendo
                case 3 
                    
                    if delta(i) > folga 
                        %Estado - Mensurando Subindo
                        Estado = 1;
                        Es(i) = 1;
                        h = 0;
                        Ganho(i) = A*U(i)*U(i) - B*U(i) + C;
                        
                    elseif (delta(i) > 0 & delta(i) <= folga)
                        %Estado - Folga na Descida
                        Estado = 4;
                        Es(i) = 4;
                        h = h + delta(i);
                        Ganho(i) = Ganho(i-1);
                                                
                    elseif delta(i) <= 0                        
                        %Estado - Mensurando Descendo
                        Estado = 3;
                        Es(i) = 3;
                        h = 0;
                        Ganho(i) = A*Ud(i)*Ud(i) - B*Ud(i) + C;

                       
                    end
                
                %Estado - Folga na Descida
                case 4
                                        
                    if (delta(i) + h) > folga
                        %Estado - Mensurando Subindo
                        Estado = 1;
                        Es(i) = 1;
                        h = 0;
                        Ganho(i) = A*U(i)*U(i) - B*U(i) + C;
                        
                    elseif ((delta(i) + h) <= folga & (delta(i) + h) >= 0) 
                        %Estado - Folga na Descida
                        Estado = 4;
                        Es(i) = 4;
                        h = h + delta(i);
                        Ganho(i) = Ganho(i-1);
                        
                    elseif (delta(i) + h) < 0
                        %Estado - Mensurando Descendo
                        Estado = 3;
                        Es(i) = 3;
                        h = 0;
                        Ganho(i) = A*Ud(i)*Ud(i) - B*Ud(i) + C;

                    end
                    
    
                case 0
                    break;
            end
    end
end


%Aplicação da Dinâmica do Sistema

%Inicialização de Coeficientes Modelo ARX e Resposta Dinâmica do Sistema

a1 = -0.2697;
b1 = 0.7303;

Y = zeros(length(Ganho),1);

Y(1) = 0;
Y(2) = 0;

for k=3:length(Y)
    Y(k) =  -a1*Y(k-1) + b1*Ganho(k-1);
end

end
