tic

%--------------------------------------
% Tear-down semua display dan variable
%--------------------------------------
clc; clear;

%--------------
% Load file IG 
%--------------
MW1_01_IG = csvread('03_SeleksiFitur\MW1_IG\MW1_IG.csv');

%-------------
% K-Fold = 5
%-------------
k = 5;
vektorMW1 = MW1_01_IG(:,1);

%--------
% Seed
%--------
seed = 9;
rng(seed); %Seed nilai random, jadi ga usah run berkali-kali

cvFolds = crossvalind('Kfold', vektorMW1, k);
clear vektorMW1; 
    
disp('MW1_IG Calculation in progress...');

for iFitur = 37 : -1 : 1 %Decrement
%---
    for iFold = 1 : k
    %---            
        
        %-------------------------------------
        % Penetapan data TRAINING dan TESTING
        %-------------------------------------
        testIdx = (cvFolds == iFold);                
        MW1_00_TrainIdx(:,iFold) = ~testIdx; %1 = training, 0 = testing        
        
        %------------------------------------------------------------------
        % Pembagian data TRANING dan TESTING berdasarkan "MW1_00_TrainIdx"        
        %------------------------------------------------------------------
        iTraining = 1; %Counter iterasi TRAINING
        iTesting = 1; %Counter iterasi TESTING                     
        for iBarisData = 1 : size(MW1_01_IG,1)  %Iterasi baris data 
            %---- TRAINING
            if MW1_00_TrainIdx(iBarisData,iFold) == 1 %Kalau TrainIdx 1                 
                MW1_02_Train{1,iFitur}{iFold,1}(iTraining,1:iFitur) = MW1_01_IG(iBarisData,1:iFitur); %Sengaja dipisah kelasnya, karena ada iterasi fitur
                MW1_02_Train{1,iFitur}{iFold,1}(iTraining,iFitur+1) = MW1_01_IG(iBarisData,end); %Tambah kelas dari kolom paling terakhir di "MW1_01_IG"
                MW1_02_Train{1,iFitur}{iFold,1}(iTraining,iFitur+2) = iBarisData; %Tambah urutan data
                iTraining = iTraining + 1; %Counter TRAINING            
            %---- TESTING
            else %kalau TrainIdx 0
                MW1_03_Test{1,iFitur}{iFold,1}(iTesting,1:iFitur) = MW1_01_IG(iBarisData,1:iFitur); %Sengaja dipisah kelasnya, karena ada iterasi fitur           
                MW1_03_Test{1,iFitur}{iFold,1}(iTesting,iFitur+1) = MW1_01_IG(iBarisData,end); %Tambah kelas dari kolom paling terakhir di "MW1_01_IG"
                MW1_03_Test{1,iFitur}{iFold,1}(iTesting,iFitur+2) = iBarisData; %Tambah urutan data
                iTesting = iTesting + 1; %Counter TESTING
            end                        
        end
        clear iBarisData iTesting iTraining;
        
        %------------------------------------------------------
        % Pembagian data TRAINING yang kelasnya FALSE dan TRUE
        %------------------------------------------------------
        fgFalse = 0; %Flag jumlah TRAINING yang FALSE
        fgTrue = 0; %Flag jumlah TRAINING yang TRUE        
        for iJumlahTrain = 1 : size(MW1_02_Train{1,iFitur}{iFold,1},1) %Iterasi panjang TRAINING  
            %---- FALSE
            if MW1_02_Train{1,iFitur}{iFold,1}(iJumlahTrain,iFitur+1) == 0 %TRAINING kelas FALSE              
                fgFalse = fgFalse + 1; %Counter TRAINING yang FALSE
                MW1_04_Train_False{1,iFitur}{iFold,1}(fgFalse,:) = MW1_02_Train{1,iFitur}{iFold,1}(iJumlahTrain,:); %Ambil data FALSE dari urutan TRAINING            
            %---- TRUE
            else %TRAINING kelas TRUE
                fgTrue = fgTrue + 1; %Counter TRAINING yang TRUE
                MW1_05_Train_True{1,iFitur}{iFold,1}(fgTrue,:) = MW1_02_Train{1,iFitur}{iFold,1}(iJumlahTrain,:); %Ambil data TRUE dari urutan TRAINING  
            end                        
        end
        clear fgFalse fgTrue iJumlahTrain;                      
                                 
        %--------------------------------------------------------------------------------------
        % Cek pemilihan titik C1 jangan sampai pilih yang duplikat dengan kelas berbeda (TRUE)
        %--------------------------------------------------------------------------------------
        kFalse{1,iFitur}{iFold,1} = randperm(size(MW1_04_Train_False{1,iFitur}{iFold,1},1)); %Acak urutan data "TRAINING FALSE"
        TrainTrue{iFold,1} = MW1_05_Train_True{1,end}{iFold,1}; %Duplikat matrik TRAINING yang kelasnya TRUE untuk cek duplikasi C1, langsung ambil semua fitur 1 hingga end
        urutanKFalse = 1; %Ambil urutan dari nilai random kFalse
        duplikatC1 = true; %Kondisi while loop
        while duplikatC1                        
            TrainTrue{iFold,1}(end+1,:) = MW1_04_Train_False{1,end}{iFold,1}( kFalse{1,end}{iFold,1}(1,urutanKFalse) ,:); %Di akhir data TRAINING TRUE ditambah satu data TRAINING FALSE, langsung semua fitur 1 hingga end
            %----------------------------------------------
            % Kalau jumlah GAK sama, berarti NO duplikasi
            %----------------------------------------------
            if size(MW1_05_Train_True{1,end}{iFold,1},1) ~= size(unique(TrainTrue{iFold,1}(:,end),'rows'),1) %Kalau dibikin uniqe (semua fitur, 1 hingga end) jumlahnya ga sama, berarti gada duplikasi
                duplikatC1 = false; %Looping while berhenti
                MW1_06_Titik_C1{1,iFitur}{iFold,1} = MW1_04_Train_False{1,iFitur}{iFold,1}( kFalse{1,end}{iFold,1}(1,urutanKFalse) ,:); %Titik C1 diambil dari TRAINING FALSE yang bukan duplikasi, dari kFalse fitur lengkap (terakhir)
            %---------------
            % ADA duplikasi
            %---------------
            else %Ketika dibikin uniqe, jumlahnya jadi sama, maka ada duplikasi data dengan kelas yang berbeda                
                TrainTrue{iFold,1}(end,:) = []; %Satu data di baris paling akhir (end) di-delete, karena bukan data asli TRAINING TRUE
                urutanKFalse = urutanKFalse + 1; %Nanti ambil urutan kFalse selanjutnya
            end            
        end 
        clear urutanKFalse duplikatC1 TrainTrue;
        
        %--------------------------------------------------------------------------------------
        % Cek pemilihan titik C2 jangan sampai pilih yang duplikat dengan kelas berbeda (FALSE)
        %--------------------------------------------------------------------------------------
        kTrue{1,iFitur}{iFold,1} = randperm(size(MW1_05_Train_True{1,iFitur}{iFold,1},1)); %Acak urutan data "TRAINING TRUE"         
        TrainFalse{iFold,1} = MW1_04_Train_False{1,end}{iFold,1}; %Duplikat matrik TRAINING yang kelasnya FALSE untuk cek duplikasi C2, langsung ambil semua fitur 1 hingga end
        urutanKTRUE = 1; %Ambil urutan dari nilai random kTRUE
        duplikatC2 = true; %Kondisi while loop
        while duplikatC2                        
            TrainFalse{iFold,1}(end+1,:) = MW1_05_Train_True{1,end}{iFold,1}( kTrue{1,end}{iFold,1}(1,urutanKTRUE) ,:); %Di akhir data TRAINING FALSE ditambah satu data TRAINING TRUE, langsung semua fitur 1 hingga end
            %----------------------------------------------
            % Kalau jumlah GAK sama, berarti NO duplikasi
            %----------------------------------------------
            if size(MW1_04_Train_False{1,end}{iFold,1},1) ~= size(unique(TrainFalse{iFold,1}(:,1:end),'rows'),1) %Kalau dibikin uniqe (semua fitur, 1 hingga end) jumlahnya ga sama, berarti gada duplikasi
                duplikatC2 = false; %Looping while berhenti
                MW1_07_Titik_C2{1,iFitur}{iFold,1} = MW1_05_Train_True{1,iFitur}{iFold,1}( kTrue{1,end}{iFold,1}(1,urutanKTRUE) ,:); %Titik C2 diambil dari TRAINING TRUE yang bukan duplikasi, dari kTrue fitur lengkap (terakhir)
            %---------------
            % ADA duplikasi
            %---------------
            else %Ketika dibikin uniqe, jumlahnya jadi sama, maka ada duplikasi data dengan kelas yang berbeda                
                TrainFalse{iFold,1}(end,:) = []; %Satu data di baris paling akhir (end) di-delete, karena bukan data asli TRAINING FALSE
                urutanKTRUE = urutanKTRUE + 1; %Nanti ambil urutan kTrue selanjutnya
            end            
        end 
        clear urutanKTRUE duplikatC2 TrainFalse;       

%         %---------------------------------------------------
%         % Tentukan C1 dari kumpulan kelas FALSE secara acak
%         %--------------------------------------------------- 
%         kFalse{1,iFitur}{iFold,1} = randperm(size(MW1_04_Train_False{1,37}{iFold,1},1)); % acak urutan data "trainingFalse"
%         MW1_06_Titik_C1{1,iFitur}{iFold,1} = MW1_04_Train_False{1,iFitur}{iFold,1}(kFalse{1,37}{iFold,1}(1,1),:); % urutan pertama hasil acak, diambil sebagai C1  
%         
%         %--------------------------------------------------
%         % Tentukan C2 dari kumpulan kelas TRUE secara acak
%         %--------------------------------------------------        
%         kTrue{1,iFitur}{iFold,1} = randperm(size(MW1_05_Train_True{1,37}{iFold,1},1)); % acak urutan data "trainingTrue"         
%         MW1_07_Titik_C2{1,iFitur}{iFold,1} = MW1_05_Train_True{1,iFitur}{iFold,1}(kTrue{1,37}{iFold,1}(1,1),:); % urutan pertama hasil acak, diambil sebagai C2         
        
%==============================================================================================
%                                    ==  FASE 1  ===
%==============================================================================================
        
        %----------------------------------------------------------------
        % Hitung hamming distance masing-masing fitur terhadap C1 dan C2
        %----------------------------------------------------------------
        for iKolomCluster = 1 : iFitur
            for iBarisCluster = 1 : size(MW1_02_Train{1,iFitur}{iFold,1},1) %Iterasi baris data per fold di setiap iterasi fitur             
                %------------------------------------
                % Hitung jarak data ke titik cluster
                %------------------------------------
                data = MW1_02_Train{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster); %Data fitur yang ke iKolomCluster

                %------------------------
                % Jarak tiap fitur ke C1
                %------------------------
                C1 = MW1_06_Titik_C1{1,iFitur}{iFold,1}(1,iKolomCluster); %Data titik C1 yang ke iKolomCluster                                
                jarakHamming = hammingDistance_fix(data,C1); %Panggil fungsi perhitungan jarak hamming dari data ke titik C1
                MW1_08_HamDist_C1{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming; %Simpan perhitungan jarak hamming C1

                %------------------------
                % Jarak tiap fitur ke C2
                %------------------------
                C2 = MW1_07_Titik_C2{1,iFitur}{iFold,1}(1,iKolomCluster); %Data titik C2 yang ke iKolomCluster                                                               
                jarakHamming = hammingDistance_fix(data,C2); %Panggil fungsi perhitungan jarak hamming dari data ke titik C2
                MW1_09_HamDist_C2{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming; %Simpan perhitungan jarak hamming C2                                           
            end 
        end
        clear iBarisCluster jarakHamming data C1 C2 iKolomCluster;
        
        %-----------------------------------------------------------------------
        % Menghitung rata-rata setiap baris hamming distance pada seleksi fitur
        %-----------------------------------------------------------------------        
        MW1_10_Avg_HamDist{1,iFitur}{iFold,1}(:,1) = mean(MW1_08_HamDist_C1{1,iFitur}{iFold,1},2); % Rata-rata per baris ke C1
        MW1_10_Avg_HamDist{1,iFitur}{iFold,1}(:,2) = mean(MW1_09_HamDist_C2{1,iFitur}{iFold,1},2); % Rata-rata per baris ke C2
        
        %--------------------------------------------------------------------------------------------------------------
        % Penentuan anggota C1 atau C2 berdasarkan jarak rata-rata terdekat --> Update kolom ke 3 "MW1_10_Avg_HamDist"
        %--------------------------------------------------------------------------------------------------------------
        for iBarisAvg = 1 : size(MW1_02_Train{1,iFitur}{iFold,1},1)
            averageC1 = MW1_10_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,1); %Jarak rata-rata baris hamming distance C1
            averageC2 = MW1_10_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,2); %Jarak rata-rata baris hamming distance C2                                    
            if averageC1 > averageC2                
                MW1_10_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,3) = 22222; %Anggota C2
            else MW1_10_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,3) = 11111; %Anggota C1
            end                                                              
        end
        clear iBarisAvg averageC1 averageC2;
           
        %----------------------------------------------------------
        % Pengelompokan data C1 dan C2 berdasarkan 11111 dan 22222
        %----------------------------------------------------------
        fgC1 = 0; %Flag counter urutan anggota C1
        fgC2 = 0; %Flag counter urutan anggota C2
        for iBarisKelompok = 1 : size(MW1_02_Train{1,iFitur}{iFold,1},1)  
            if MW1_10_Avg_HamDist{1,iFitur}{iFold,1}(iBarisKelompok,3) == 11111 %Kalau data lebih dekat ke C1, maka jadi anggota C1     
                fgC1 = fgC1 + 1; %Counter flag C1 untuk urutan anggota C1
                MW1_11_Anggota_C1{1,iFitur}{iFold,1}(fgC1,:) = MW1_02_Train{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2); %Ambil semua baris data TRAINING, termasuk kelas dan urutannya                
            else %Kalau data lebih dekat ke C2, maka jadi anggota C2     
                fgC2 = fgC2 + 1; %Counter flag C2 untuk urutan anggota C2
                MW1_12_Anggota_C2{1,iFitur}{iFold,1}(fgC2,:) = MW1_02_Train{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2); %Ambil semua baris data TRAINING, termasuk kelas dan urutannya
            end                        
        end
        %-------------------------------------------------------------------------------------------------------------
        % Prevent Fold "MW1_12_Anggota_C2" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []  
        %-------------------------------------------------------------------------------------------------------------
        if size(MW1_11_Anggota_C1{1,iFitur}{iFold,1},1) == size(MW1_02_Train{1,iFitur}{iFold,1},1) %Jumlah anggota C1 == jumlah data TRAINING, maka anggota C2 = []
            MW1_12_Anggota_C2{1,iFitur}{iFold,1} = []; %Anggota C2 dibuat matrik kosong
        end        
        clear fgC1 fgC2 iBarisKelompok;    
        
        %----------------------------------
        % Hitung MEAN per fitur anggota C1
        %----------------------------------
        MW1_13_Mean_C1{1,iFitur}{iFold,1}(1,:) = mean(MW1_11_Anggota_C1{1,iFitur}{iFold,1}(:,1:iFitur)); %Hitung mean per kolom anggota C1               
        
        %----------------------------------
        % Hitung MEAN per fitur anggota C2
        %----------------------------------
        if size(MW1_12_Anggota_C2{1,iFitur},1) ~= 0 %Cek apakah FOLD ada datanya? Kalau ada, lanjut...
            if size(MW1_12_Anggota_C2{1,iFitur}{iFold,1},1) ~= 0 %Cek apakah data per FOLD ada? Kalau ada, lanjut...                  
                %---------------------------------------------------------
                % Kondisi kalau baris datanya cuma 1, ga usah hitung mean
                %---------------------------------------------------------
                if size(MW1_12_Anggota_C2{1,iFitur}{iFold,1},1) == 1
                    MW1_14_Mean_C2{1,iFitur}{iFold,1}(1,:) = MW1_12_Anggota_C2{1,iFitur}{iFold,1}; %Ga usah hitung mean, karena cuma satu data
                else
                    MW1_14_Mean_C2{1,iFitur}{iFold,1}(1,:) = mean(MW1_12_Anggota_C2{1,iFitur}{iFold,1}(:,1:iFitur)); %Hitung mean per kolom anggota C2
                end                  
            end            
        end         
        %----------------------------------------------------------------------------------------------------------
        % Prevent Fold "MW1_14_Mean_C2" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []  
        %----------------------------------------------------------------------------------------------------------
        if size(MW1_11_Anggota_C1{1,iFitur}{iFold,1},1) == size(MW1_02_Train{1,iFitur}{iFold,1},1) %Jumlah anggota C1 == jumlah data TRAINING, maka MEAN C2 = []
            MW1_14_Mean_C2{1,iFitur}{iFold,1} = []; %Mean C2 dibuat matrik kosong
        end
        
        %-------------------------------------------------
        % Pembulatan nilai MEAN --> C1 "new" dan C2 "new"
        %-------------------------------------------------        
        for iSeleksiFitur = 1 : iFitur                        
            %---------
            % MEAN C1
            %---------
            nilaiMeanC1 = MW1_13_Mean_C1{1,iFitur}{iFold,1}(1,iSeleksiFitur); %Nilai mean C1 per TOP iFitur
            pembulatanC1 = pembulatanMEAN_fix(nilaiMeanC1); %Pembualatan data C1 per fitur
            MW1_15_Titik_C1_New{1,iFitur}{iFold,1}(1,iSeleksiFitur) = pembulatanC1; %Simpan setiap pembulatan data C1 per fitur --> Jadi C1 New            
            %---------
            % MEAN C2
            %---------
            if size(MW1_14_Mean_C2{1,iFitur},1) ~= 0 %Cek fitur 'MW1_14_Mean_C2' metrik kosong bukan, kalau bukan, lanjut..
                if size(MW1_14_Mean_C2{1,iFitur}{iFold,1},1) ~= 0 %Cek fold 'MW1_14_Mean_C2' metrik kosong bukan, kalau bukan, lanjut..
                    nilaiMeanC2 = MW1_14_Mean_C2{1,iFitur}{iFold,1}(1,iSeleksiFitur); %Nilai mean C2 per TOP iFitur
                    pembulatanC2 = pembulatanMEAN_fix(nilaiMeanC2); %Pembualatan data C2 per fitur
                    MW1_16_Titik_C2_New{1,iFitur}{iFold,1}(1,iSeleksiFitur) = pembulatanC2; %Simpan setiap pembulatan data C2 per fitur --> Jadi C2 New
                end
            end             
            %------------------------------------------------------------------------------------------------
            % Prevent Fold < 10 untuk anggota C2, jadi metrik kosong di akhir dianggap tidak ada sama matLab    
            %------------------------------------------------------------------------------------------------
            if size(MW1_11_Anggota_C1{1,iFitur}{iFold,1},1) == size(MW1_02_Train{1,iFitur}{iFold,1},1) %Jumlah anggota C1 == jumlah data TRAINING, maka C2 New = []
                MW1_16_Titik_C2_New{1,iFitur}{iFold,1} = []; %Titik C2 new dibuat matrik kosong, karena memang gada anggotanya
            end            
        end
        clear iSeleksiFitur nilaiMeanC1 nilaiMeanC2 pembulatanC1 pembulatanC2                        
        
%==============================================================================================
%                                    ==  FASE 2  ===
%==============================================================================================        
            
        %----------------------------------------------------------------------------
        % Hitung hamming distance masing-masing fitur terhadap "C1_new" dan "C2_new"
        %----------------------------------------------------------------------------
        for iKolomCluster = 1 : iFitur
            for iBarisCluster = 1 : size(MW1_02_Train{1,iFitur}{iFold,1},1)              
                %-------------------------------------------
                % Hitung jarak data ke titik cluster "new"
                %-------------------------------------------
                data = MW1_02_Train{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster);

                %------------------------------
                % Jarak tiap fitur ke "C1_new"
                %------------------------------
                C1 = MW1_15_Titik_C1_New{1,iFitur}{iFold,1}(1,iKolomCluster);                                
                jarakHamming = hammingDistance_fix(data,C1);
                MW1_17_HamDist_C1_new{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming;

                %------------------------------
                % Jarak tiap fitur ke "C2_new"
                %------------------------------                
                if size(MW1_16_Titik_C2_New{1,iFitur}{iFold,1},1) ~= 0                                        
                    C2 = MW1_16_Titik_C2_New{1,iFitur}{iFold,1}(1,iKolomCluster);                  
                    jarakHamming = hammingDistance_fix(data,C2);
                    MW1_18_HamDist_C2_new{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming;                    
                else
                    MW1_18_HamDist_C2_new{1,iFitur}{iFold,1} = [];
                end                
            end
        end
        clear iBarisCluster jarakHamming data C1 C2 iKolomCluster;                        
        
        %-----------------------------------------------------------------------
        % Menghitung rata-rata setiap baris hamming distance pada seleksi fitur
        %-----------------------------------------------------------------------        
        MW1_19_Avg_HamDist_new{1,iFitur}{iFold,1}(:,1) = mean(MW1_17_HamDist_C1_new{1,iFitur}{iFold,1},2); % Rata-rata per baris
            %---------------------------------------------------------
            % Selama tidak ada metrik kosong pada hamming distance C2
            %---------------------------------------------------------
        if size(MW1_18_HamDist_C2_new{1,iFitur}{iFold,1},1) ~= 0 
            MW1_19_Avg_HamDist_new{1,iFitur}{iFold,1}(:,2) = mean(MW1_18_HamDist_C2_new{1,iFitur}{iFold,1},2); % Rata-rata per baris
            %--------------------------------------------------
            % Kalau ADA metrik kosong pada hamming distance C2
            %--------------------------------------------------
        else
            for iKosong = 1 : size(MW1_02_Train{1,iFitur}{iFold,1},1)
                MW1_19_Avg_HamDist_new{1,iFitur}{iFold,1}(iKosong,2) = 9999; % Sengaja dibuat jauh jaraknya
            end            
        end 
        clear iKosong;
        
        %-------------------------------------------------------------------------------
        % Penentuan anggota "C1_new" atau "C2_new" berdasarkan jarak rata-rata terdekat
        %-------------------------------------------------------------------------------
        for iBarisAvg = 1 : size(MW1_02_Train{1,iFitur}{iFold,1},1)        
            averageC1 = MW1_19_Avg_HamDist_new{1,iFitur}{iFold,1}(iBarisAvg,1);            
            averageC2 = MW1_19_Avg_HamDist_new{1,iFitur}{iFold,1}(iBarisAvg,2);                                 
            if averageC1 > averageC2                                
                MW1_19_Avg_HamDist_new{1,iFitur}{iFold,1}(iBarisAvg,3) = 22222;
            else MW1_19_Avg_HamDist_new{1,iFitur}{iFold,1}(iBarisAvg,3) = 11111;
            end                                                                                                                                                                  
        end
        clear iBarisAvg averageC1 averageC2;           
        
        %----------------------------------------------------------------------
        % Pengelompokan data "C1_new" dan "C2_new" berdasarkan 11111 dan 22222
        %----------------------------------------------------------------------
        fgC1 = 0;
        fgC2 = 0;
        for iBarisKelompok = 1 : size(MW1_02_Train{1,iFitur}{iFold,1},1)  
            if MW1_19_Avg_HamDist_new{1,iFitur}{iFold,1}(iBarisKelompok,3) == 11111     
                fgC1 = fgC1 + 1;
                MW1_20_Anggota_C1_new{1,iFitur}{iFold,1}(fgC1,:) = MW1_02_Train{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);                
            else
                fgC2 = fgC2 + 1;
                MW1_21_Anggota_C2_new{1,iFitur}{iFold,1}(fgC2,:) = MW1_02_Train{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);
            end                        
        end
        %-----------------------------------------------------------------------------------------------------------------
        % Prevent Fold "MW1_21_Anggota_C2_new" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []  
        %-----------------------------------------------------------------------------------------------------------------
        if size(MW1_20_Anggota_C1_new{1,iFitur}{iFold,1},1) == size(MW1_02_Train{1,iFitur}{iFold,1},1)
            MW1_21_Anggota_C2_new{1,iFitur}{iFold,1} = [];
        end        
        clear fgC1 fgC2 iBarisKelompok;  
        
%==============================================================================================
%                                    ==  WHILE  ===
%==============================================================================================                        
        
        %------------------------------------------------------------------------------------------
        % 1. Cek apakah anggota C1 dan C2 yang lama sudah sama dengan yang baru? If ya = konvergen
        % 2. If tidak = Hitung lagi, cari anggota C1 dan C2 yang baru
        %------------------------------------------------------------------------------------------
        MW1_22_____________________ = 0;
        MW1_23_Anggota_C1_Awal{1,iFitur}{iFold,1} = MW1_11_Anggota_C1{1,iFitur}{iFold,1};
        MW1_24_Anggota_C2_Awal{1,iFitur}{iFold,1} = MW1_12_Anggota_C2{1,iFitur}{iFold,1};         
        MW1_25_____________________ = 0;        
        MW1_26_Anggota_C1_Temp{1,iFitur}{iFold,1} = MW1_20_Anggota_C1_new{1,iFitur}{iFold,1};               
        %------------------------------------------------------------------------------------------------------------------
        % Prevent Fold "MW1_27_Anggota_C2_Temp" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []
        %------------------------------------------------------------------------------------------------------------------
        if size(MW1_24_Anggota_C2_Awal{1,iFitur}{iFold,1},1) ~=0            
            MW1_27_Anggota_C2_Temp{1,iFitur}{iFold,1} = MW1_24_Anggota_C2_Awal{1,iFitur}{iFold,1};
        else MW1_27_Anggota_C2_Temp{1,iFitur}{iFold,1} = [];
        end                                                               
        MW1_28_____________________ = 0;       
        
        %-------------------------------------------
        % Untuk menghitung iterasi hingga konvergen
        %-------------------------------------------
        MW1_44_JumlahIterasi{1,iFitur}{iFold,1} = 0;

        %--------------------------------------------------------------------------
        % Cek dulu apakah LENGTH anggota C1 (awal) == LENGTH anggota C1_new (temp)
        %--------------------------------------------------------------------------
        if size(MW1_23_Anggota_C1_Awal{1,iFitur}{iFold,1},1) == size(MW1_26_Anggota_C1_Temp{1,iFitur}{iFold,1},1)
            %------------------------------------------------------------------------------------------------
            % Cek apakah susunan masing-masing anggota sudah sama? Kalau YA, langsung ambil titik C1 dan C2
            %------------------------------------------------------------------------------------------------
            if MW1_23_Anggota_C1_Awal{1,iFitur}{iFold,1} == MW1_26_Anggota_C1_Temp{1,iFitur}{iFold,1}
                Joss{1,iFitur}{iFold,1} = 11111;
                MW1_31_Titik_C1_Temp{1,iFitur}{iFold,1} = MW1_15_Titik_C1_New{1,iFitur}{iFold,1};
                MW1_32_Titik_C2_Temp{1,iFitur}{iFold,1} = MW1_16_Titik_C2_New{1,iFitur}{iFold,1};
            %--------------------------------------------------------------------
            % Kalau susunan beda, lakukan iterasi hingga kedua anggota konvergen
            %--------------------------------------------------------------------
            else
                Joss{1,iFitur}{iFold,1} = [];
                MW1_44_JumlahIterasi{1,iFitur}{iFold,1} = MW1_44_JumlahIterasi{1,iFitur}{iFold,1} + 1; %counter iterasi
                %------------------------------------
                % Cari anggota baru hingga konvergen
                %------------------------------------
                konvergensi_fix; %Panggil method WHILE konvergen                
            end
        else
            Joss{1,iFitur}{iFold,1} = [];
            MW1_44_JumlahIterasi{1,iFitur}{iFold,1} = MW1_44_JumlahIterasi{1,iFitur}{iFold,1} + 1; %counter iterasi
            %------------------------------------
            % Cari anggota baru hingga konvergen
            %------------------------------------
            konvergensi_fix; %Panggil method WHILE konvergen            
        end
          
%==============================================================================================
%                                   ==  TESTING  ===
%==============================================================================================    
        %---------------------------------------------------------        
        %Pengujian per FOLD (ada 5) di setiap iterasi TOP X FITUR
        %---------------------------------------------------------        
        testing_fix;
                
    %---    
    end
%---
end

[nilai,urutan] = max(MW1_50_Mean_PD);
MW1_55_MAX_Mean_PD = [seed,nilai,urutan]; %record nilai maximum PD dan urutan ke berapa

clear cvFolds iFold testIdx k iFitur konvergen kFalse kTrue nilai urutan seed;

toc

MW1_55_MAX_Mean_PD(1,4) = size(MW1_01_IG,2)-1; %Simpan jumlah banyaknya fitur
MW1_55_MAX_Mean_PD(1,5) = toc; %Simpan nilai elapsed time (seconds)

disp('Saving...');
    tic
        save('04_CBC\MW1_IG_CBC_FOLD_5.mat');        
    toc
disp('Done!');

load gong %chirp
sound(y,Fs)
clear y Fs;