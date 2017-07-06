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
                MW1_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,4) = MW1_03_Test{1,iFitur}{iFold,1}(iBarisAvg,end-1); %Penambahan kelas sebagai ground truth
            else
                MW1_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,3) = 11111;
                MW1_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,4) = MW1_03_Test{1,iFitur}{iFold,1}(iBarisAvg,end-1); %Penambahan kelas sebagai ground truth
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
        
%         %-----------------------------------------------------------------------------------------------------------------
%         % Prevent Fold "MW1_43_Test_Anggota_C2" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []  
%         %-----------------------------------------------------------------------------------------------------------------
%         if size(MW1_42_Test_Anggota_C1{1,iFitur}{iFold,1},1) ~= 0
%             if size(MW1_42_Test_Anggota_C1{1,iFitur}{iFold,1},1) == size(MW1_03_Test{1,iFitur}{iFold,1},1)
%                 MW1_43_Test_Anggota_C2{1,iFitur}{iFold,1} = [];
%             end
%         end        
%         
%         %-----------------------------------------------------------------------------------------------------------------
%         % Prevent Fold "MW1_42_Test_Anggota_C1" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []  
%         %-----------------------------------------------------------------------------------------------------------------
%         if size(MW1_43_Test_Anggota_C2{1,iFitur}{iFold,1},1) ~= 0
%             if size(MW1_43_Test_Anggota_C2{1,iFitur}{iFold,1},1) == size(MW1_03_Test{1,iFitur}{iFold,1},1)
%                 MW1_42_Test_Anggota_C1{1,iFitur}{iFold,1} = [];
%             end
%         end   
                                
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