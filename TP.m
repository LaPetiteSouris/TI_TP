%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                     TRANSMISSION DE L'INFORMATION                     %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Ce code vous est une simple proposition suivant � peu de chose pr�s le
% sujet du TP. Libre � vous de le modifier comme vous le souhaitez.

% METTEZ TOUT EN COMMENTAIRE AVANT DE COMMENCER LE TP
% AU FUR ET A MESURE DE VOTRE AVANCEMENT, TESTEZ VOTRE CODE...


clear all 
close all
clc

disp('Le message suivant va �tre compress� (par Huffman), transmis, puis d�compress� :'),

texte = 'TESTDETI';
%texte = 'CECIESTUNEDEMOCETTEPHRASEVAETRECOMPRESSEEPARLECODEDEHUFFMAN';
%texte = 'ABCDEFGHIJKLMOPQRSTUVWXYZ';

disp(texte);

%% 1ere partie du TP : cryptage
% *************************************************************************

% % Chiffrement
% cle = input('Quelle est la cl� de chiffrement ?');
% texte = cryptage(texte, cle);
% disp(' ');
% disp('Le cryptogramme est :');
% commentaire = texte;
% disp(commentaire);
% pause

%% 2eme partie du TP : codage de Huffman
% *************************************************************************

% Entropie
H = entropie(texte);
disp(' ');
disp('L''entropie de la source est :');
commentaire = strcat('H=',num2str(H),' bits');
disp(commentaire);

% Compression de Huffman
[texte_compr,arbre] = huffman_compr(texte);
disp(' ');
disp('Le code calcul� est :');
for i = 1 : length(arbre)
    commentaire = strcat(char(arbre(i).info),'-->',arbre(i).valeur);
    disp(commentaire);
end

% Longueur moyenne des mots de code
%Avant, on va compter le nombre de mot de code Huffman
%Le valeur retourbe s est un vector, 2ere element et le nombre de mot
%de code, qui est le nombre de struct dans arbre. Chaque struct est un mot
%de code
s=size(arbre);
nb=s(2);
%
Long_moy = 0; 
%Longeur moyenne=sum(longueur_mot_de_code*frequence)
for i=1:nb
    Long_moy=Long_moy+arbre(i).frequence*length(arbre(i).valeur);
end
disp(' ');
disp('La longueur moyenne des symboles de code est :');
commentaire = strcat('n=',num2str(Long_moy),' bits');
disp(commentaire);

% Calcul du taux de compression
% Sans compression
%n bits pour stocker maximum 2^n character
Nb_bits =  ceil(log2(length(texte)));
disp(' ');
disp('Sans compression, le nombre de symboles binaires par lettre source est :');
commentaire = strcat('n=',num2str(Nb_bits),' bits');
disp(commentaire);
Nb_bits_SC = length(texte)*Nb_bits;
% Avec compression
Nb_bits_AC = length(texte_compr); 
Taux = (1-Nb_bits_AC/Nb_bits_SC)*100;
disp(' ');
disp('Le taux de compression est :');
commentaire = strcat( 'T=', num2str(Taux), ' %');
disp(commentaire);

%% 2eme partie du TP : codage de canal
% *************************************************************************

% Codes correcteur d'erreur
% --------------------------------------------------------------

%  Matrice g�n�ratrice
G=[1 1 1 0 0 0 0 ;...
   1 0 0 1 1 0 0 ;...
   0 1 0 1 0 1 0 ;...
   1 1 0 1 0 0 1];

% Taille du vecteur d'info et de code
%Nombre de ligne de matrice G
[k,n]=size(G);

% Nombre de mots � coder dans la variable texte_compr
Nb_info = length(texte_compr);

% On d�coupe le vecteur compress� en paquets de k digits et on va contruire
% une matrice i qui contient k colonne, chaque ligen est une partie le
% longeur k de texte_compr.

i=buffer(texte_compr,k,0);
i=i';

%Matrice contient les mots de code. Chaque ligne est une mot de code

mot_de_code_matrice=i*G;
mot_de_code_matrice=mod(mot_de_code_matrice,2);
%flux binaire des mots de code
code = reshape(mot_de_code_matrice.',1,[]);


% PARAMETRES POUR SIMULINK
% Simulation de la transmission
fe_simulink = 50000;
% Dur�e / amplitude des symboles
Tsymbole_simulink = 70;
Asymbole_simulink = 5;
code_simulink = [code];
% Vecteur d'entr�e de la simulation
t_simulink = [0:length(code_simulink)-1]*Tsymbole_simulink/fe_simulink;
entree_simulink = [t_simulink', code_simulink'];

%% SIMULINK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim('simulation.mdl')
% 
% 
% %% Analyse des erreurs
% % --------------------------------------------------------------
% 
% % Analyse du code
% % *** A COMPLETER ***
% 
% % D�calage li� � la transmission
% Ndecalage = ; % *** A COMPLETER ***
% code_recu = ; % *** A COMPLETER ***
% code_emis = ; % *** A COMPLETER ***
% 
% % Vecteurs d'erreur
% % *** A COMPLETER ***
% % Nombre d'erreur
% % *** A COMPLETER ***
% 
% % D�tection/correction des erreurs
% % --------------------------------------------------------------
% 
% % Matrice de contr�le
% H = [0 0 0 1 1 1 1; ...
%      0 1 1 0 0 1 1; ...
%      1 0 1 0 1 0 1];
% 
% % Correction des erreurs
% for i =1:Nb_info
%     
%     % Sans correction d'erreur --------------------
%     info_non_corrigee(..) = ; % *** A COMPLETER ***
%     
%     % Avec correction des erreurs -----------------
%     % Calcul du syndrome
%     s = ; % *** A COMPLETER ***
%     % Position de l'erreur
%     pos_e = ; % *** A COMPLETER ***
%     % Correction du code re�u
%     code_corrige(..) = ; % *** A COMPLETER ***
%     % Extraction de l'information
%     info_corrigee(..) = ; % *** A COMPLETER ***
%     
% end
% 
% % D�compression
% texte_envoye = huffman_decompr(texte_compr,arbre);
% %texte_envoye = decryptage(texte_envoye, cle);
% disp(' ');
% disp('Le message d�compress� (SANS transmission) est :');
% disp(texte_envoye);
% 
% texte_recu = huffman_decompr(info_non_corrigee,arbre);
% %texte_recu = decryptage(texte_recu, cle);
% disp(' ');
% disp('Le message d�compress� (AVEC transmission, SANS code correcteur) est :');
% disp(texte_recu);
% 
% texte_recu_corrige = huffman_decompr(info_corrigee,arbre);
% %texte_recu_corrige = decryptage(texte_recu_corrige, cle);
% disp(' ');
% disp('Le message d�compress� (AVEC transmission, AVEC code correcteur) est :');
% disp(texte_recu_corrige);
% disp(' ')
% 
% % Taux d'erreur par caract�re
% % Sans prise en compte de la redondance
% nb_err = ; % *** A COMPLETER ***
% tau_err = ; % *** A COMPLETER ***
% disp('Taux d''erreur caract�re (SANS code correcteur) :');
% fprintf('  - Nombre d''erreur : %i\n',nb_err)
% fprintf('  - Taux d''erreur : %.2f%%\n', tau_err);
% % En tenant compte de la redondance (code correcteur)
% nb_err = ; % *** A COMPLETER ***
% tau_err = ; % *** A COMPLETER ***
% disp('Taux d''erreur caract�re (AVEC code correcteur) :');
% fprintf('  - Nombre d''erreur : %i\n',nb_err)
% fprintf('  - Taux d''erreur : %.2f%%\n', tau_err);
% 
% %% Evolution des taux d'erreurs en fonction du RSB
% % *************************************************************************
% 
% % *** A COMPLETER ***