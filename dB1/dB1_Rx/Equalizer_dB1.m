function [Equalized, Equalized_PCA, RsCinrdB, ChanResponseGrid, ChanResponseGrid_PCA] = ...
         Equalizer_dB1(TxGrid, RxGrid, UsePCA)

% 1. Definitions
%--------------------------------------------------------------------------

EqualizerGrid        = ones(600, 40);
ChanResponseGrid     = ones(600, 40);
ChanResponseGrid_PCA = ones(600, 40);
Equalized            = ones(600, 80);
Equalized_PCA        = ones(600, 80);
RsCinrdB             = zeros(40, 1); % SNR estimate at each reference symbol

% 2. Compute Channel Response and Equalizer coefficients for each OFDM reference symbol
%--------------------------------------------------------------------------

GridSymbolNum = 1;
for SymbolNum = 1:2:79

  RefSigsA    = RxGrid(1:299, SymbolNum);
  RefSigsB    = RxGrid(302:600, SymbolNum);
  IdealSigsA  = TxGrid(1:299, SymbolNum);
  IdealSigsB  = TxGrid(302:600, SymbolNum);
  
  ChanResponseGrid(1:299, GridSymbolNum)   = RefSigsA ./ IdealSigsA;
  ChanResponseGrid(302:600, GridSymbolNum) = RefSigsB ./ IdealSigsB;
  ChanResponseGrid(300:301, GridSymbolNum) =  1;

  EqualizerGrid(:, GridSymbolNum) = 1 ./ ChanResponseGrid(:, GridSymbolNum);
    
  GridSymbolNum = GridSymbolNum + 1;
end

figure(40);
plot(1:600, real(ChanResponseGrid(1:600, 1))); hold on;
plot(1:600, imag(ChanResponseGrid(1:600, 1)));
title('Symbol 1 Frequency Response - Raw');

% 3. Equalize each OFDM symbol with the appropriate reference signals
%--------------------------------------------------------------------------

GridSymbolNum = 1;
for SymbolNum = 2:2:80
  Equalized(:, SymbolNum) = RxGrid(:, SymbolNum) .* EqualizerGrid(:, GridSymbolNum);
  GridSymbolNum = GridSymbolNum + 1;
end

% Plot for testing.
for SymbolNum = 2:2:80
    figure(44);
    plot(real(Equalized(:,SymbolNum)), imag(Equalized(:,SymbolNum)), 'k.', 'MarkerSize', 10);
    hold on; grid on; xlabel('real'); ylabel('imag'); axis([-2.5 2.5 -2.5 2.5]);
    title('Equalized Constellation - Raw');
end

% 4. If using PCA, equalize each OFDM symbol with the appropriate reference signals
%--------------------------------------------------------------------------

if (UsePCA == 1) % Refine the estimate using principle component analysis

  %[Channel_Estimate_PCA, SnrEst] =  ComputeEigenDecomposition(ChanResponseGrid(1:600, 1), 1);
  %ChanResponseGrid_PCA(:, 1) = Channel_Estimate_PCA;
  %RsCinrdB(1, 1)             = SnrEst;
  
  GridSymbolNum = 1;
  for SymbolNum = 2:2:80
    [Channel_Estimate_PCA, SnrEst]  = ComputeEigenDecomposition(ChanResponseGrid(1:600, GridSymbolNum), 1);
    RsCinrdB(GridSymbolNum, 1)      = SnrEst;
    Equalized_PCA(:, SymbolNum)     = RxGrid(:, SymbolNum) ./ Channel_Estimate_PCA;
    
    if (GridSymbolNum == 1)
      ChanEstimateForPlot = Channel_Estimate_PCA;
    end

    GridSymbolNum = GridSymbolNum + 1;

  end

  figure(48);
  plot(1:600, real(ChanEstimateForPlot)); hold on;
  plot(1:600, imag(ChanEstimateForPlot));
  title('Symbol 1 Frequency Response - RS-CINR Estimation');
  
  for SymbolNum = 2:2:80
    figure(52);
    plot(real(Equalized_PCA(:,SymbolNum)), imag(Equalized_PCA(:,SymbolNum)), 'k.', 'MarkerSize', 10);
    hold on; grid on; xlabel('real'); ylabel('imag'); axis([-2.5 2.5 -2.5 2.5]);
    title('Equalized Constellation - PCA Filtered');
  end

else
  Equalized_PCA = zeros(600, 80);
  RsCinrdB      = 0;
end

end
