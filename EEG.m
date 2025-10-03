% Datei einlesen
data = readtable('EEG.csv')  
f = data.F8  % EEG-Signal aus Ableitung F8


% Filter definieren
M3 = 1/3 * [1 1 1]           % Mittelwert-Filter M3
G3 = 1/8 * [2 4 2]           % Gauß-Filter G3
M5 = 1/5 * [1 1 1 1 1]       % Mittelwert-Filter M5

% G5: Diskrete Gauß-Approximation (Pascal-Dreieck)
G5 = 1/16 * [1 4 6 4 1]

% Faltung anwenden
f_out_M3 = conv(f, M3, 'same')  % mit gleitendem Mittelwert
f_out_G3 = conv(f, G3, 'same')  % mit Gauß-Filter
f_out_M5 = conv(f, M5, 'same')
f_out_G5 = conv(f, G5, 'same')
myG5 = 1/16 * [1 3 8 3 1]   % Summe = 12 → normalisiert
f_out_myG5 = conv(f, myG5, 'same');


figure(1)
hold on
plot(f) % Originalsignal
plot(f_out_M3)
plot(f_out_G3 )
plot(f_out_M5 )
plot(f_out_G5 )
plot(f_out_myG5)
legend("EEG","G3","M3","G5","M5","myG5")
xlabel("Var1") 
ylabel(" Amplitude [ mV]") 
title("EEG-Signal") 

figure(2) % zackenbereich
hold on;
range = 1700:2100
plot(f(range))
plot( f_out_M3(range))
plot(f_out_G3(range))
plot( f_out_M5(range))
plot(f_out_G5(range))
plot( f_out_myG5(range))
legend("EEG","G3","M3","G5","M5","myG5")
xlabel("Var1") 
ylabel(" Amplitude [ mV]") 
title("EEG-Signal") 




