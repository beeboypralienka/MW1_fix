tic

%--------------------------------------
% Tear-down semua display dan variable
%--------------------------------------
clc; clear;

%--------------
% Load file GR 
%--------------
MW1_01_GR = csvread('03_SeleksiFitur\MW1_GR\MW1_GR.csv');

%-------------
% K-Fold = 5
%-------------
k = 5;
vektorMW1 = MW1_01_GR(:,1);
rng(9);
cvFolds = crossvalind('Kfold', vektorMW1, k);
clear vektorMW1; 
    
disp('MW1_GR Calculation in progress...');

for iFitur = 37 : -1 : 1
%---
    for iFold = 1 : k
    %---
    
        %-------------------------------------------
        % Untuk menghitung iterasi hingga konvergen
        %-------------------------------------------
        MW1_44_JumlahIterasi{1,iFitur}{iFold,1} = 0;
        
        %-------------------------------------
        % Penetapan data TRAINING dan TESTING
        %-------------------------------------
        testIdx = (cvFolds == iFold);                
        MW1_00_TrainIdx(:,iFold) = ~testIdx;        
        
        %------------------------------------------------------------------
        % Pembagian data TRANING dan TESTING berdasarkan "MW1_00_TrainIdx"        
        %------------------------------------------------------------------
        iTraining = 1; 
        iTesting = 1;                     
        for iBarisData = 1 : size(MW1_01_GR,1)            
            if MW1_00_TrainIdx(iBarisData,iFold) == 1 %---- TRAINING                 
                MW1_02_Train{1,iFitur}{iFold,1}(iTraining,1:iFitur) = MW1_01_GR(iBarisData,1:iFitur); 
                MW1_02_Train{1,iFitur}{iFold,1}(iTraining,iFitur+1) = MW1_01_GR(iBarisData,38); % Tambah kelas
                MW1_02_Train{1,iFitur}{iFold,1}(iTraining,iFitur+2) = iBarisData; % Tambah urutan data
                iTraining = iTraining + 1;            
            else %---- TESTING                                        
                MW1_03_Test{1,iFitur}{iFold,1}(iTesting,1:iFitur) = MW1_01_GR(iBarisData,1:iFitur);            
                MW1_03_Test{1,iFitur}{iFold,1}(iTesting,iFitur+1) = MW1_01_GR(iBarisData,38); % Tambah kelas
                MW1_03_Test{1,iFitur}{iFold,1}(iTesting,iFitur+2) = iBarisData; % Tambah urutan data
                iTesting = iTesting + 1;
            end                        
        end
        clear iBarisData iTesting iTraining;
        
        %------------------------------------------------------
        % Pembagian data TRAINING yang kelasnya FALSE dan TRUE
        %------------------------------------------------------
        fgFalse = 0;
        fgTrue = 0;        
        for iJumlahTrain = 1 : size(MW1_02_Train{1,iFitur}{iFold,1},1)  
            %---- FALSE
            if MW1_02_Train{1,iFitur}{iFold,1}(iJumlahTrain,iFitur+1) == 0               
                fgFalse = fgFalse + 1;
                MW1_04_Train_False{1,iFitur}{iFold,1}(fgFalse,:) = MW1_02_Train{1,iFitur}{iFold,1}(iJumlahTrain,:);             
            %---- TRUE
            else 
                fgTrue = fgTrue + 1;
                MW1_05_Train_True{1,iFitur}{iFold,1}(fgTrue,:) = MW1_02_Train{1,iFitur}{iFold,1}(iJumlahTrain,:); 
            end                        
        end
        clear fgFalse fgTrue iJumlahTrain;                      
                                 
        %--------------------------------------------------------------------------------------
        % Cek pemilihan titik C1 jangan sampai pilih yang duplikat dengan kelas berbeda (TRUE)
        %--------------------------------------------------------------------------------------
        kFalse{1,iFitur}{iFold,1} = randperm(size(MW1_04_Train_False{1,iFitur}{iFold,1},1)); % acak urutan data "trainingFalse"
        TrainTrue{iFold,1} = MW1_05_Train_True{1,37}{iFold,1};
        urutan = 1;
        duplikatC1 = true;
        while duplikatC1                        
            TrainTrue{iFold,1}(end+1,:) = MW1_04_Train_False{1,37}{iFold,1}(kFalse{1,37}{iFold,1}(1,urutan),:);
            %----------------------------------------------
            % Kalau jumlah GAK sama, berarti NO duplikasi
            %----------------------------------------------
            if size(MW1_05_Train_True{1,37}{iFold,1},1) ~= size(unique(TrainTrue{iFold,1}(:,1:37),'rows'),1)
                duplikatC1 = false;
                MW1_06_Titik_C1{1,iFitur}{iFold,1} = MW1_04_Train_False{1,iFitur}{iFold,1}(kFalse{1,37}{iFold,1}(1,urutan),:); % urutan pertama hasil acak, diambil sebagai C1  
            %---------------
            % ADA duplikasi
            %---------------
            else                
                TrainTrue{iFold,1}(end,:) = [];
                urutan = urutan + 1;
            end            
        end 
        clear urutan duplikatC1 TrainTrue;
        
        %--------------------------------------------------------------------------------------
        % Cek pemilihan titik C2 jangan sampai pilih yang duplikat dengan kelas berbeda (FALSE)
        %--------------------------------------------------------------------------------------
        kTrue{1,iFitur}{iFold,1} = randperm(size(MW1_05_Train_True{1,iFitur}{iFold,1},1)); % acak urutan data "trainingTrue"         
        TrainFalse{iFold,1} = MW1_04_Train_False{1,37}{iFold,1};
        urutan = 1;
        duplikatC2 = true;
        while duplikatC2                        
            TrainFalse{iFold,1}(end+1,:) = MW1_05_Train_True{1,37}{iFold,1}(kTrue{1,37}{iFold,1}(1,urutan),:);
            %----------------------------------------------
            % Kalau jumlah GAK sama, berarti NO duplikasi
            %----------------------------------------------
            if size(MW1_04_Train_False{1,37}{iFold,1},1) ~= size(unique(TrainFalse{iFold,1}(:,1:37),'rows'),1)
                duplikatC2 = false;
                MW1_07_Titik_C2{1,iFitur}{iFold,1} = MW1_05_Train_True{1,iFitur}{iFold,1}(kTrue{1,37}{iFold,1}(1,urutan),:); % urutan pertama hasil acak, diambil sebagai C1  
            %---------------
            % ADA duplikasi
            %---------------
            else                
                TrainFalse{iFold,1}(end,:) = [];
                urutan = urutan + 1;
            end            
        end 
        clear urutan duplikatC2 TrainFalse;       

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
            for iBarisCluster = 1 : size(MW1_02_Train{1,iFitur}{iFold,1},1)              
                %------------------------------------
                % Hitung jarak data ke titik cluster
                %------------------------------------
                data = MW1_02_Train{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster);

                %------------------------
                % Jarak tiap fitur ke C1
                %------------------------
                C1 = MW1_06_Titik_C1{1,iFitur}{iFold,1}(1,iKolomCluster);                                
                jarakHamming = hammingDistance_fix(data,C1);
                MW1_08_HamDist_C1{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming;

                %------------------------
                % Jarak tiap fitur ke C2
                %------------------------
                C2 = MW1_07_Titik_C2{1,iFitur}{iFold,1}(1,iKolomCluster);                                
                jarakHamming = hammingDistance_fix(data,C2);
                MW1_09_HamDist_C2{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming;                                           
            end 
        end
        clear iBarisCluster jarakHamming data C1 C2 iKolomCluster;
        
        %-----------------------------------------------------------------------
        % Menghitung rata-rata setiap baris hamming distance pada seleksi fitur
        %-----------------------------------------------------------------------        
        MW1_10_Avg_HamDist{1,iFitur}{iFold,1}(:,1) = mean(MW1_08_HamDist_C1{1,iFitur}{iFold,1},2); % Rata-rata per baris
        MW1_10_Avg_HamDist{1,iFitur}{iFold,1}(:,2) = mean(MW1_09_HamDist_C2{1,iFitur}{iFold,1},2); % Rata-rata per baris
        
        %-------------------------------------------------------------------
        % Penentuan anggota C1 atau C2 berdasarkan jarak rata-rata terdekat
        %-------------------------------------------------------------------
        for iBarisAvg = 1 : size(MW1_02_Train{1,iFitur}{iFold,1},1)
            averageC1 = MW1_10_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,1);
            averageC2 = MW1_10_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,2);                                    
            if averageC1 > averageC2                
                MW1_10_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,3) = 22222;
            else MW1_10_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,3) = 11111;
            end                                                              
        end
        clear iBarisAvg averageC1 averageC2;
           
        %----------------------------------------------------------
        % Pengelompokan data C1 dan C2 berdasarkan 11111 dan 22222
        %----------------------------------------------------------
        fgC1 = 0;
        fgC2 = 0;
        for iBarisKelompok = 1 : size(MW1_02_Train{1,iFitur}{iFold,1},1)  
            if MW1_10_Avg_HamDist{1,iFitur}{iFold,1}(iBarisKelompok,3) == 11111     
                fgC1 = fgC1 + 1;
                MW1_11_Anggota_C1{1,iFitur}{iFold,1}(fgC1,:) = MW1_02_Train{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);                
            else
                fgC2 = fgC2 + 1;
                MW1_12_Anggota_C2{1,iFitur}{iFold,1}(fgC2,:) = MW1_02_Train{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);
            end                        
        end
        %-------------------------------------------------------------------------------------------------------------
        % Prevent Fold "MW1_12_Anggota_C2" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []  
        %-------------------------------------------------------------------------------------------------------------
        if size(MW1_11_Anggota_C1{1,iFitur}{iFold,1},1) == size(MW1_02_Train{1,iFitur}{iFold,1},1)
            MW1_12_Anggota_C2{1,iFitur}{iFold,1} = [];
        end        
        clear fgC1 fgC2 iBarisKelompok;    
        
        %----------------------------------
        % Hitung MEAN per fitur anggota C1
        %----------------------------------
        MW1_13_Mean_C1{1,iFitur}{iFold,1}(1,:) = mean(MW1_11_Anggota_C1{1,iFitur}{iFold,1}(:,1:iFitur));                 
        
        %----------------------------------
        % Hitung MEAN per fitur anggota C2
        %----------------------------------
        if size(MW1_12_Anggota_C2{1,iFitur},1) ~= 0            
            if size(MW1_12_Anggota_C2{1,iFitur}{iFold,1},1) ~= 0                  
                %---------------------------------------------------------
                % Kondisi kalau baris datanya cuma 1, ga usah hitung mean
                %---------------------------------------------------------
                if size(MW1_12_Anggota_C2{1,iFitur}{iFold,1},1) == 1
                    MW1_14_Mean_C2{1,iFitur}{iFold,1}(1,:) = MW1_12_Anggota_C2{1,iFitur}{iFold,1};
                else MW1_14_Mean_C2{1,iFitur}{iFold,1}(1,:) = mean(MW1_12_Anggota_C2{1,iFitur}{iFold,1}(:,1:iFitur));       
                end                  
            end            
        end         
        %----------------------------------------------------------------------------------------------------------
        % Prevent Fold "MW1_14_Mean_C2" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []  
        %----------------------------------------------------------------------------------------------------------
        if size(MW1_11_Anggota_C1{1,iFitur}{iFold,1},1) == size(MW1_02_Train{1,iFitur}{iFold,1},1)
            MW1_14_Mean_C2{1,iFitur}{iFold,1} = [];
        end
        
        %-------------------------------------------------
        % Pembulatan nilai MEAN --> C1 "new" dan C2 "new"
        %-------------------------------------------------        
        for iSeleksiFitur = 1 : iFitur                        
            %---------
            % MEAN C1
            %---------
            nilaiMeanC1 = MW1_13_Mean_C1{1,iFitur}{iFold,1}(1,iSeleksiFitur);
            pembulatanC1 = pembulatanMEAN_fix(nilaiMeanC1);
            MW1_15_Titik_C1_New{1,iFitur}{iFold,1}(1,iSeleksiFitur) = pembulatanC1;            
            %---------
            % MEAN C2
            %---------
            if size(MW1_14_Mean_C2{1,iFitur},1) ~= 0
                if size(MW1_14_Mean_C2{1,iFitur}{iFold,1},1) ~= 0
                    nilaiMeanC2 = MW1_14_Mean_C2{1,iFitur}{iFold,1}(1,iSeleksiFitur);
                    pembulatanC2 = pembulatanMEAN_fix(nilaiMeanC2);
                    MW1_16_Titik_C2_New{1,iFitur}{iFold,1}(1,iSeleksiFitur) = pembulatanC2;
                end
            end             
            %------------------------------------------------------------------------------------------------
            % Prevent Fold < 10 untuk anggota C2, jadi metrik kosong di akhir dianggap tidak ada sama matLab    
            %------------------------------------------------------------------------------------------------
            if size(MW1_11_Anggota_C1{1,iFitur}{iFold,1},1) == size(MW1_02_Train{1,iFitur}{iFold,1},1)
                MW1_16_Titik_C2_New{1,iFitur}{iFold,1} = [];
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
                                
        %------------------------------------
        % Cari anggota baru hingga konvergen
        %------------------------------------
        konvergen = true;
        while konvergen          
        %--                               
            %-----------------------------------------
            % Hitung MEAN per fitur anggota C1 "temp"
            %-----------------------------------------
            MW1_29_Mean_C1_Temp{1,iFitur}{iFold,1}(1,:) = mean(MW1_26_Anggota_C1_Temp{1,iFitur}{iFold,1}(:,1:iFitur));                 
   
            %-----------------------------------------
            % Hitung MEAN per fitur anggota C2 "temp"
            %-----------------------------------------
            if size(MW1_27_Anggota_C2_Temp{1,iFitur},1) ~= 0            
                if size(MW1_27_Anggota_C2_Temp{1,iFitur}{iFold,1},1) ~= 0                  
                    %---------------------------------------------------------
                    % Kondisi kalau baris datanya cuma 1, ga usah hitung mean
                    %---------------------------------------------------------
                    if size(MW1_27_Anggota_C2_Temp{1,iFitur}{iFold,1},1) == 1
                        MW1_30_Mean_C2_Temp{1,iFitur}{iFold,1}(1,:) = MW1_27_Anggota_C2_Temp{1,iFitur}{iFold,1};
                    else MW1_30_Mean_C2_Temp{1,iFitur}{iFold,1}(1,:) = mean(MW1_27_Anggota_C2_Temp{1,iFitur}{iFold,1}(:,1:iFitur));       
                    end                  
                end
            end         
            %---------------------------------------------------------------------------------------------------------------
            % Prevent Fold "MW1_28_Mean_C2_Temp" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []  
            %---------------------------------------------------------------------------------------------------------------
            if size(MW1_26_Anggota_C1_Temp{1,iFitur}{iFold,1},1) == size(MW1_02_Train{1,iFitur}{iFold,1},1)
                MW1_30_Mean_C2_Temp{1,iFitur}{iFold,1} = [];
            end
        
            %-----------------------------------------------------------
            % Pembulatan nilai MEAN --> C1 "new Temp" dan C2 "new Temp"
            %-----------------------------------------------------------
            for iSeleksiFitur = 1 : iFitur                        
                %---------
                % MEAN C1
                %---------
                nilaiMeanC1 = MW1_29_Mean_C1_Temp{1,iFitur}{iFold,1}(1,iSeleksiFitur);
                pembulatanC1 = pembulatanMEAN_fix(nilaiMeanC1);
                MW1_31_Titik_C1_Temp{1,iFitur}{iFold,1}(1,iSeleksiFitur) = pembulatanC1;            
                %---------
                % MEAN C2
                %---------                
                if size(MW1_30_Mean_C2_Temp{1,iFitur}{iFold,1},1) ~= 0                    
                    nilaiMeanC2 = MW1_30_Mean_C2_Temp{1,iFitur}{iFold,1}(1,iSeleksiFitur);
                    pembulatanC2 = pembulatanMEAN_fix(nilaiMeanC2);
                    MW1_32_Titik_C2_Temp{1,iFitur}{iFold,1}(1,iSeleksiFitur) = pembulatanC2;
                end                
                %------------------------------------------------------------------------------------------------
                % Prevent Fold < 10 untuk anggota C2, jadi metrik kosong di akhir dianggap tidak ada sama matLab    
                %------------------------------------------------------------------------------------------------
                if size(MW1_26_Anggota_C1_Temp{1,iFitur}{iFold,1},1) == size(MW1_02_Train{1,iFitur}{iFold,1},1)
                    MW1_32_Titik_C2_Temp{1,iFitur}{iFold,1} = [];
                end            
            end
            clear iSeleksiFitur nilaiMeanC1 nilaiMeanC2 pembulatanC1 pembulatanC2
            
            %------------------------------------------------------------------------------
            % Hitung hamming distance masing-masing fitur terhadap "C1_temp" dan "C2_temp"
            %------------------------------------------------------------------------------
            for iKolomCluster = 1 : iFitur
                for iBarisCluster = 1 : size(MW1_02_Train{1,iFitur}{iFold,1},1)              
                    %-------------------------------------------
                    % Hitung jarak data ke titik cluster "temp"
                    %-------------------------------------------
                    data = MW1_02_Train{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster);
                    %-------------------------------
                    % Jarak tiap fitur ke "C1_temp"
                    %-------------------------------
                    C1 = MW1_31_Titik_C1_Temp{1,iFitur}{iFold,1}(1,iKolomCluster);                                
                    jarakHamming = hammingDistance_fix(data,C1);
                    MW1_33_HamDist_C1_Temp{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming;
                    %------------------------------
                    % Jarak tiap fitur ke "C2_temp"
                    %------------------------------                
                    if size(MW1_32_Titik_C2_Temp{1,iFitur}{iFold,1},1) ~= 0                                        
                        C2 = MW1_32_Titik_C2_Temp{1,iFitur}{iFold,1}(1,iKolomCluster);                  
                        jarakHamming = hammingDistance_fix(data,C2);
                        MW1_34_HamDist_C2_Temp{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming;                    
                    else MW1_34_HamDist_C2_Temp{1,iFitur}{iFold,1} = [];
                    end                
                end
            end
            clear iBarisCluster jarakHamming data C1 C2 iKolomCluster;
            
            %---------------------------------------------------------------------------
            % Menghitung rata-rata hamming distance "temp" C1 dan C2 pada seleksi fitur
            %---------------------------------------------------------------------------
            MW1_35_Avg_HamDist_Temp{1,iFitur}{iFold,1}(:,1) = mean(MW1_33_HamDist_C1_Temp{1,iFitur}{iFold,1},2); % Rata-rata per baris
            %---------------------------------------------------------
            % Selama tidak ada metrik kosong pada hamming distance C2
            %---------------------------------------------------------
            if size(MW1_34_HamDist_C2_Temp{1,iFitur}{iFold,1},1) ~= 0 
                MW1_35_Avg_HamDist_Temp{1,iFitur}{iFold,1}(:,2) = mean(MW1_34_HamDist_C2_Temp{1,iFitur}{iFold,1},2); % Rata-rata per baris
            %--------------------------------------------------
            % Kalau ADA metrik kosong pada hamming distance C2
            %--------------------------------------------------
            else
                for iKosong = 1 : size(MW1_02_Train{1,iFitur}{iFold,1},1)
                    MW1_35_Avg_HamDist_Temp{1,iFitur}{iFold,1}(iKosong,2) = 9999; % Sengaja dibuat jauh jaraknya
                end            
            end 
            clear iKosong;                                  
            
            %----------------------------------------------------------------------------------------
            % Penentuan status anggota "C1_temp" atau "C2_temp" berdasarkan jarak rata-rata terdekat
            %----------------------------------------------------------------------------------------
            for iBarisAvg = 1 : size(MW1_02_Train{1,iFitur}{iFold,1},1)        
                averageC1 = MW1_35_Avg_HamDist_Temp{1,iFitur}{iFold,1}(iBarisAvg,1);            
                averageC2 = MW1_35_Avg_HamDist_Temp{1,iFitur}{iFold,1}(iBarisAvg,2);                                 
                if averageC1 > averageC2                                
                    MW1_35_Avg_HamDist_Temp{1,iFitur}{iFold,1}(iBarisAvg,3) = 22222;
                else MW1_35_Avg_HamDist_Temp{1,iFitur}{iFold,1}(iBarisAvg,3) = 11111;
                end                                                                                                                                                                  
            end
            clear iBarisAvg averageC1 averageC2; 
                        
            %------------------------------------------------------------------------
            % Pengelompokan data "C1_Temp" dan "C2_Temp" berdasarkan 11111 dan 22222
            %------------------------------------------------------------------------
            fgC1 = 0;
            fgC2 = 0;
            for iBarisKelompok = 1 : size(MW1_02_Train{1,iFitur}{iFold,1},1)  
                if MW1_35_Avg_HamDist_Temp{1,iFitur}{iFold,1}(iBarisKelompok,3) == 11111     
                    fgC1 = fgC1 + 1;
                    MW1_36_Anggota_C1_newTemp{1,iFitur}{iFold,1}(fgC1,:) = MW1_02_Train{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);                
                else                    
                    fgC2 = fgC2 + 1;
                    MW1_21_Anggota_C2_newTemp{1,iFitur}{iFold,1}(fgC2,:) = MW1_02_Train{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);                                        
                end                                                                  
            end
            %-----------------------------------------------------------------------------------------------------------------
            % Prevent Fold "MW1_21_Anggota_C2_new" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []  
            %-----------------------------------------------------------------------------------------------------------------
            if size(MW1_36_Anggota_C1_newTemp{1,iFitur}{iFold,1},1) == size(MW1_02_Train{1,iFitur}{iFold,1},1)
                MW1_21_Anggota_C2_newTemp{1,iFitur}{iFold,1} = [];
            end        
            clear fgC1 fgC2 iBarisKelompok;            
            
            %---------------------------------
            % Nilai "Temp" dipindah ke "Awal"
            %---------------------------------
            MW1_23_Anggota_C1_Awal{1,iFitur}{iFold,1} = MW1_26_Anggota_C1_Temp{1,iFitur}{iFold,1};
            MW1_24_Anggota_C2_Awal{1,iFitur}{iFold,1} = MW1_27_Anggota_C2_Temp{1,iFitur}{iFold,1};
            
            %------------------------------------
            % Nilai "NewTemp" dipindah ke "Temp"
            %------------------------------------
            MW1_26_Anggota_C1_Temp{1,iFitur}{iFold,1} = MW1_36_Anggota_C1_newTemp{1,iFitur}{iFold,1};
            MW1_27_Anggota_C2_Temp{1,iFitur}{iFold,1} = MW1_21_Anggota_C2_newTemp{1,iFitur}{iFold,1};            
            
            %------------------------------------------------
            % Kondisi kalau sudah konvergen, "Awal" = "Temp"
            %------------------------------------------------
            if size(MW1_23_Anggota_C1_Awal{1,iFitur}{iFold,1},1) == size(MW1_26_Anggota_C1_Temp{1,iFitur}{iFold,1},1)
                if MW1_23_Anggota_C1_Awal{1,iFitur}{iFold,1} == MW1_26_Anggota_C1_Temp{1,iFitur}{iFold,1}
                    konvergen = false;                
                    break
                else
                    MW1_44_JumlahIterasi{1,iFitur}{iFold,1} = MW1_44_JumlahIterasi{1,iFitur}{iFold,1} + 1;
                    %------------------------------
                    % Pembatasan iterasi konvergen
                    %------------------------------
                    if MW1_44_JumlahIterasi{1,iFitur}{iFold,1} == 1000
                        konvergen = false;
                        break;
                    end
                end
            end            
        %--                                                    
        end 
        clear MW1_36_Anggota_C1_newTemp MW1_21_Anggota_C2_newTemp;
        
%==============================================================================================
%                                   ==  TESTING  ===
%==============================================================================================         
        
        %----------------------------------------------------------------
        % Hitung hamming distance TESTING terhadap titik C1 dan C2 temp
        %----------------------------------------------------------------        
        MW1_38________________________ = 0;        
        for iKolomCluster = 1 : iFitur
            for iBarisCluster = 1 : size(MW1_03_Test{1,iFitur}{iFold,1},1)              
                %--------------------------------------------
                % Hitung jarak data TESTING ke titik cluster
                %--------------------------------------------
                data = MW1_03_Test{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster);

                %--------------------------------
                % Jarak tiap fitur TESTING ke C1
                %--------------------------------
                C1 = MW1_31_Titik_C1_Temp{1,iFitur}{iFold,1}(1,iKolomCluster);                                
                jarakHamming = hammingDistance_fix(data,C1);
                MW1_39_Test_HamDist_C1{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming;

                %--------------------------------
                % Jarak tiap fitur TESTING ke C2
                %--------------------------------
                if size(MW1_32_Titik_C2_Temp{1,iFitur}{iFold,1},1) ~= 0                                        
                    C2 = MW1_32_Titik_C2_Temp{1,iFitur}{iFold,1}(1,iKolomCluster);                                
                    jarakHamming = hammingDistance_fix(data,C2);
                    MW1_40_Test_HamDist_C2{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming;
                else
                    MW1_40_Test_HamDist_C2{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = 999999;
                end                
            end 
        end
        clear iBarisCluster jarakHamming data C1 C2 iKolomCluster;
        
        %-----------------------------------------------------------------------
        % Menghitung rata-rata setiap baris hamming distance pada seleksi fitur
        %-----------------------------------------------------------------------        
        MW1_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(:,1) = mean(MW1_39_Test_HamDist_C1{1,iFitur}{iFold,1},2); % Rata-rata per baris        
        MW1_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(:,2) = mean(MW1_40_Test_HamDist_C2{1,iFitur}{iFold,1},2); % Rata-rata per baris
        
        %-------------------------------------------------------------------
        % Penentuan anggota C1 atau C2 berdasarkan jarak rata-rata terdekat
        %-------------------------------------------------------------------
        for iBarisAvg = 1 : size(MW1_03_Test{1,iFitur}{iFold,1},1)
            averageC1 = MW1_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,1);
            averageC2 = MW1_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,2);                                    
            if averageC1 > averageC2                
                MW1_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,3) = 22222;
            else MW1_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,3) = 11111;
            end                                                              
        end
        clear iBarisAvg averageC1 averageC2;       
        
        %-----------------------------------------------------------------------
        % Pengelompokan data "C1_Test" dan "C2_Test" berdasarkan 11111 dan 22222
        %-----------------------------------------------------------------------
        fgC1 = 0;
        fgC2 = 0;
        for iBarisKelompok = 1 : size(MW1_03_Test{1,iFitur}{iFold,1},1)              
            if MW1_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisKelompok,3) == 11111                     
                fgC1 = fgC1 + 1;
                MW1_42_Test_Anggota_C1{1,iFitur}{iFold,1}(fgC1,:) = MW1_03_Test{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);                
            else     
                fgC2 = fgC2 + 1;
                MW1_43_Test_Anggota_C2{1,iFitur}{iFold,1}(fgC2,:) = MW1_03_Test{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);                             
            end                                                                  
        end           
        
        %----------------------------------------------------------------------
        % Cek kalau avg kelompoknya C2 semua atau C1 semua,
        % tar dibuat matrik kosong, soalnya matlab menganggap tidak ada matrik
        %----------------------------------------------------------------------
        if fgC1 == size(MW1_03_Test{1,iFitur}{iFold,1},1)
            MW1_43_Test_Anggota_C2{1,iFitur}{iFold,1} = [];                 
        elseif fgC2 == size(MW1_03_Test{1,iFitur}{iFold,1},1)
            MW1_42_Test_Anggota_C1{1,iFitur}{iFold,1} = [];
        end
        clear fgC1 fgC2 iBarisKelompok;                                  
        
        %-----------------------------------------------------------------------------------------------------------------
        % Prevent Fold "MW1_43_Test_Anggota_C2" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []  
        %-----------------------------------------------------------------------------------------------------------------
        if size(MW1_42_Test_Anggota_C1{1,iFitur}{iFold,1},1) ~= 0
            if size(MW1_42_Test_Anggota_C1{1,iFitur}{iFold,1},1) == size(MW1_03_Test{1,iFitur}{iFold,1},1)
                MW1_43_Test_Anggota_C2{1,iFitur}{iFold,1} = [];
            end
        end        
        
        %-----------------------------------------------------------------------------------------------------------------
        % Prevent Fold "MW1_42_Test_Anggota_C1" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []  
        %-----------------------------------------------------------------------------------------------------------------
        if size(MW1_43_Test_Anggota_C2{1,iFitur}{iFold,1},1) ~= 0
            if size(MW1_43_Test_Anggota_C2{1,iFitur}{iFold,1},1) == size(MW1_03_Test{1,iFitur}{iFold,1},1)
                MW1_42_Test_Anggota_C1{1,iFitur}{iFold,1} = [];
            end
        end   
                                
%==============================================================================================
%                              ==  MW1_45_TP_ && MW1_46_FP_  ===
%==============================================================================================         

        %-----------------------------------------
        % Kalau anggota C2 emang gada sama sekali
        %-----------------------------------------
        countTP = 0;
        countFP = 0;
        if size(MW1_43_Test_Anggota_C2{1,iFitur}{iFold,1},1) == 0
            MW1_45_TP_{1,iFitur}{iFold,1} = 0;
            MW1_46_FP_{1,iFitur}{iFold,1} = 0;
        %---------------------------------------    
        % Ada anggota C2, maka hitung TP dan FP
        %---------------------------------------
        else 
            %--------------------------------
            % Cek anggota C2 untuk TP dan FP
            %--------------------------------
            for iBarisC2 = 1 : size(MW1_43_Test_Anggota_C2{1,iFitur}{iFold,1},1)
                if MW1_43_Test_Anggota_C2{1,iFitur}{iFold,1}(iBarisC2,iFitur+1) == 1
                    countTP = countTP + 1;
                    MW1_45_TP_{1,iFitur}{iFold,1} = countTP;
                else
                    countFP = countFP + 1;
                    MW1_46_FP_{1,iFitur}{iFold,1} = countFP;
                end            
            end                                          
        end
        %--------------------------------------------------
        % Kondisi kalau kelasnya 0 semua atau 1 semua di C2
        %--------------------------------------------------
        if countFP == size(MW1_43_Test_Anggota_C2{1,iFitur}{iFold,1},1)
            MW1_45_TP_{1,iFitur}{iFold,1} = 0;
        elseif countTP == size(MW1_43_Test_Anggota_C2{1,iFitur}{iFold,1},1)
            MW1_46_FP_{1,iFitur}{iFold,1} = 0;
        end
        clear countTP countFP iBarisC2;
                               
%==============================================================================================
%                             ==  MW1_47_FN_ && MW1_48_TN_  ===
%============================================================================================== 
              
        %-----------------------------------------
        % Kalau anggota C1 emang gada sama sekali
        %-----------------------------------------
        countFN = 0;
        countTN = 0;   
        if size(MW1_42_Test_Anggota_C1{1,iFitur}{iFold,1},1) == 0
            MW1_47_FN_{1,iFitur}{iFold,1} = 0;
            MW1_48_TN_{1,iFitur}{iFold,1} = 0;
        %----------------
        % C1 ada anggota
        %----------------
        else    
            %--------------------------------
            % Cek anggota C2 untuk FN dan TN
            %--------------------------------
            for iBarisC2 = 1 : size(MW1_42_Test_Anggota_C1{1,iFitur}{iFold,1},1)
                if MW1_42_Test_Anggota_C1{1,iFitur}{iFold,1}(iBarisC2,iFitur+1) == 1
                    countFN = countFN + 1;
                    MW1_47_FN_{1,iFitur}{iFold,1} = countFN;                
                else
                    countTN = countTN + 1;
                    MW1_48_TN_{1,iFitur}{iFold,1} = countTN;
                end            
            end                    
        end  
        %--------------------------------------------------
        % Kondisi kalau kelasnya 0 semua atau 1 semua di C1
        %--------------------------------------------------
        if countFN == size(MW1_42_Test_Anggota_C1{1,iFitur}{iFold,1},1)
            MW1_48_TN_{1,iFitur}{iFold,1} = 0;
        elseif countTN == size(MW1_42_Test_Anggota_C1{1,iFitur}{iFold,1},1)
            MW1_47_FN_{1,iFitur}{iFold,1} = 0;
        end
        clear countFN countTN iBarisC2;
        
%==============================================================================================
%                                ==  MW1_49_PD && MW1_50_PF  ===
%==============================================================================================
        
        %-----------------
        % PD = tp/(tp+fn)
        %-----------------
        MW1_49_PD{1,iFitur}(iFold,1) = MW1_45_TP_{1,iFitur}{iFold,1}/(MW1_45_TP_{1,iFitur}{iFold,1} + MW1_47_FN_{1,iFitur}{iFold,1});
        %---------
        % Mean PD
        %---------
        MW1_50_Mean_PD(1,iFitur) = (mean(MW1_49_PD{1,iFitur}(:,1)))*100; % Mean hitung ke bawah, bukan ke samping
        
        %-----------------
        % PF = fp/(fp+tn)        
        %-----------------
        MW1_51_PF{1,iFitur}(iFold,1) = MW1_46_FP_{1,iFitur}{iFold,1}/(MW1_46_FP_{1,iFitur}{iFold,1} + MW1_48_TN_{1,iFitur}{iFold,1});
        %---------
        % Mean PF
        %---------
        MW1_52_Mean_PF(1,iFitur) = (mean(MW1_51_PF{1,iFitur}(:,1)))*100; % Mean hitung ke bawah, bukan ke samping
        
        %-----------------------------------------------------
        % Balance = 1 - ( sqrt((0-pf)^2+(1-pd)^2) / sqrt(2) )
        %-----------------------------------------------------        
        MW1_53_BAL{1,iFitur}(iFold,1) = 1 - ( sqrt( ((0 - MW1_51_PF{1,iFitur}(iFold,1))^2) + ((1 - MW1_49_PD{1,iFitur}(iFold,1))^2) ) / sqrt(2) );
        %--------------
        % Mean Balance
        %--------------
        MW1_54_Mean_BAL(1,iFitur) = (mean(MW1_53_BAL{1,iFitur}(:,1)))*100; % Mean hitung ke bawah, bukan ke samping
        
    %---    
    end
%---
end
clear cvFolds iFold testIdx k iFitur konvergen kFalse kTrue;

toc

disp('Saving...');
    tic
        save('04_CBC\MW1_GR_CBC_FOLD_5.mat');        
    toc
disp('Done!');

load gong %chirp
sound(y,Fs)
clear y Fs;