%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                     TRANSMISSION DE L'INFORMATION                     %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Ce code vous est une simple proposition suivant à peu de chose près le
% sujet du TP. Libre à vous de le modifier comme vous le souhaitez.

% METTEZ TOUT EN COMMENTAIRE AVANT DE COMMENCER LE TP
% AU FUR ET A MESURE DE VOTRE AVANCEMENT, TESTEZ VOTRE CODE...


clear all 
close all
clc

disp('Le message suivant va être compressé (par Huffman), transmis, puis décompressé :'),

texte = 'TESTDETI';        % initilisation
%texte = 'CECIESTUNEDEMOCETTEPHRASEVAETRECOMPRESSEEPARLECODEDEHUFFMAN';
%texte = 'ABCDEFGHIJKLMOPQRSTUVWXYZ';

disp(texte);

%% 1ere partie du TP : cryptage
% *************************************************************************

% % Chiffrement
cle = input('Quelle est la clé de chiffrement ?')
texte =     cryptage(texte, cle);
disp(' ');
disp('Le cryptogramme est :');
commentaire = texte;
disp(commentaire);
pause

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
disp('Le code calculé est :');
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

%  Matrice génératrice
G=[1 1 1 0 0 0 0 ;...
   1 0 0 1 1 0 0 ;...
   0 1 0 1 0 1 0 ;...
   1 1 0 1 0 0 1];

% Taille du vecteur d'info et de code

[k,n]=size(G);

% Nombre de mots a coder dans la variable texte_compr
Nb_info = length(texte);

% On découpe le vecteur compression en paquets de k digits et on va contruire
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
% Durée / amplitude des symboles
Tsymbole_simulink = 70;
Asymbole_simulink = 5;
code_simulink = [code];
% Vecteur d'entropie de la simulation
t_simulink = [0:length(code_simulink)-1]*Tsymbole_simulink/fe_simulink;
entree_simulink = [t_simulink', code_simulink'];

%% SIMULINK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim('simulation2.mdl')
% 
% 
% %% Analyse des erreurs
% % --------------------------------------------------------------
% 
% % Analyse du code
% % *** A COMPLETER ***

% Décalage ligne de la transmission
Ndecalage = 2; 
code_recu = sortie_simulink'; 
code_emis = code; % 
code_r_decalage=circshift(code_recu,[1 length(code_emis)-Ndecalage]);
vect=code_r_decalage+code_emis;
% % Vecteurs d'erreur
vect_erreur=mod(vect,2);
% % Nombre d'erreur
disp('Le nombre totale des erreurs dans trasmission est :');
erreur=length(find(vect_erreur==1))

% 
% % Detection/correction des erreurs
% % --------------------------------------------------------------
% 
% % Matrice de controle
H = [0 0 0 1 1 1 1; ...
     0 1 1 0 0 1 1; ...
     1 0 1 0 1 0 1];
 
 %Transpose de matrice de controle
 Ht=H';
 %coupe le code recu et contruire un matrice de code recu
 y=buffer(code_r_decalage, n, 0);
 y=y';
 %Remarque s_y=y*H_transpose
 s_y=mod(y*Ht,2);
 %e=table des erreurs
 e=syndtable(H);
 %     % Calcul du syndrome
 %syndrome=e*H_transpose
 syndrome=e*Ht;

 
% 
% % Correction des erreurs
%     
%     % Avec correction des erreurs --------------------
[n_ligne, n_col]=size(s_y);
%     % Position de l'erreur
[~,index_derreur_dans_syndrome]=ismember(s_y, syndrome,'rows')
%     % Correction du code reçu
%matrice de bits recu-corrige

%taille de matrice y
[n_ligne_y, n_col_y]=size(y);
code_corrige_mat=zeros(n_ligne_y,n_col_y);

for j=1:n_ligne_y
    code_corrige_mat(j,1:end)=y(j,1:end)-e(index_derreur_dans_syndrome(j),1:end);
end

%Matrice de flux binaire contenu le flux corrige
code_corrige_mat=mod(code_corrige_mat,2);
% flux binaire corrige
code_corrige = reshape(code_corrige_mat.',1,[]);

% %message binaire contenu infomation
% %les bits de l'information sont bits 3 5 6 et 7, selon matrice G
info_corrige=zeros(n_ligne_y,4);
info_corrige(1:end,1)=code_corrige_mat(1:end,3);
info_corrige(1:end,2)=code_corrige_mat(1:end,5);
info_corrige(1:end,3)=code_corrige_mat(1:end,6);
info_corrige(1:end,4)=code_corrige_mat(1:end,7);
% 
% %contruire flux binaire contenu le message texte 
info_corrige=reshape(info_corrige.',1,[]);
info_corrige=double(info_corrige);
texte_avec_correction=huffman_decompr(info_corrige, arbre);
disp('Le message décompressé (AVEC transmission, AVEC code correcteur) est :')
texte_avec_correction=texte_avec_correction(1:Nb_info)


%% Sans correction d'erreur --------------------
%%
% %message binaire contenu infomation
% %les bits de l'information sont bits 3 5 6 et 7, selon matrice G
info_non_corrige=zeros(n_ligne_y,4);
info_non_corrige(1:end,1)=y(1:end,3);
info_non_corrige(1:end,2)=y(1:end,5);
info_non_corrige(1:end,3)=y(1:end,6);
info_non_corrige(1:end,4)=y(1:end,7);
% 
% %contruire flux binaire contenu le message texte 
info_non_corrige=reshape(info_non_corrige.',1,[]);
info_non_corrige=double(info_non_corrige);
texte_non_corrige=huffman_decompr(info_non_corrige, arbre);
disp('Le message décompressé (AVEC transmission, SANS code correcteur) est :')
texte_non_corrige=texte_non_corrige(1:Nb_info)


%%Commentaire sur la capacite de correction:
%Partie supplementaire
%On va afficher la position des erreurs dans la trasmissions

disp('Position des erreurs dans le matrice binaire trasmis. Position de 1 est un erreur :')
pos_e=mod(y-mot_de_code_matrice,2)

disp('Position des erreurs deja corriges . Position de 1 est un erreur deja corrige. :')
pos_e_corrige=mod(code_corrige_mat-y,2)


%% Décompression
texte_envoye = huffman_decompr(double(texte_compr),arbre);
texte_envoye='HELLOWORLDITISME';
texte_envoye=cryptage(texte_envoye,'P')
texte_envoye = decryptage(texte_envoye, cle)

%%



