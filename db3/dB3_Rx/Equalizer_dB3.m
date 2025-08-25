function [Equalized, Equalized_PCA, RsCinrdB, ChanResponseGrid, ChanResponseGrid_PCA] = ...
         Equalizer_dB3(TxGrid, RxGrid, UsePCA)

% 1. Definitions
%--------------------------------------------------------------------------

EqualizerGrid        = ones(72, 28);
ChanResponseGrid     = ones(72, 28);
ChanResponseGrid_PCA = ones(72, 28);
Equalized            = ones(72, 56);
Equalized_PCA        = ones(72, 56);
RsCinrdB             = zeros(28, 1); % SNR estimate at each reference symbol

% 2. Compute Channel Response and Equalizer coefficients for each OFDM reference symbol
%--------------------------------------------------------------------------

GridSymbolNum = 1;
for SymbolNum = 1:2:55

  RefSigsA    = RxGrid(1:35, SymbolNum);
  RefSigsB    = RxGrid(38:72, SymbolNum);
  IdealSigsA  = TxGrid(1:35, SymbolNum);
  IdealSigsB  = TxGrid(38:72, SymbolNum);
  
  ChanResponseGrid(1:35, GridSymbolNum)  = RefSigsA ./ IdealSigsA;
  ChanResponseGrid(38:72, GridSymbolNum) = RefSigsB ./ IdealSigsB;
  ChanResponseGrid(36:37, GridSymbolNum) = 1;

  EqualizerGrid(:, GridSymbolNum) = 1 ./ ChanResponseGrid(:, GridSymbolNum);
    
  GridSymbolNum = GridSymbolNum + 1;
end

figure(40);
plot(1:72, real(ChanResponseGrid(1:72, 1))); hold on;
plot(1:72, imag(ChanResponseGrid(1:72, 1)));
title('Symbol 1 Frequency Response - Raw');

% 3. Equalize each OFDM symbol with the appropriate reference signals
%--------------------------------------------------------------------------

GridSymbolNum = 1;
for SymbolNum = 2:2:56
  Equalized(:, SymbolNum) = RxGrid(:, SymbolNum) .* EqualizerGrid(:, GridSymbolNum);
  GridSymbolNum = GridSymbolNum + 1;
end

% Plot for testing.
for SymbolNum = 2:2:56
    figure(44);
    plot(real(Equalized(:,SymbolNum)), imag(Equalized(:,SymbolNum)), 'k.', 'MarkerSize', 10);
    hold on; grid on; xlabel('real'); ylabel('imag'); axis([-2.5 2.5 -2.5 2.5]);
    title('Equalized Constellation - Raw');
end


% 4. If using PCA, equalize each OFDM symbol with the appropriate reference signals
%--------------------------------------------------------------------------

if (UsePCA == 1) % Refine the estimate using principle component analysis
 
  GridSymbolNum = 1;
  for SymbolNum = 2:2:56
    [Channel_Estimate_PCA, SnrEst]  = ComputeEigenDecomposition_dB3(ChanResponseGrid(1:72, GridSymbolNum), 1);
    RsCinrdB(GridSymbolNum, 1)      = SnrEst;
    Equalized_PCA(:, SymbolNum)     = RxGrid(:, SymbolNum) ./ Channel_Estimate_PCA;
    
    if (GridSymbolNum == 1)
      ChanEstimateForPlot = Channel_Estimate_PCA;
    end

    GridSymbolNum = GridSymbolNum + 1;

  end

  figure(48);
  plot(1:72, real(ChanEstimateForPlot)); hold on;
  plot(1:72, imag(ChanEstimateForPlot));
  title('Symbol 1 Frequency Response - RS-CINR Estimation');
  
  for SymbolNum = 2:2:56
    figure(52);
    plot(real(Equalized_PCA(:,SymbolNum)), imag(Equalized_PCA(:,SymbolNum)), 'k.', 'MarkerSize', 10);
    hold on; grid on; xlabel('real'); ylabel('imag'); axis([-2.5 2.5 -2.5 2.5]);
    title('Equalized Constellation - PCA Filtered');
  end

else
  Equalized_PCA = zeros(72, 56);
  RsCinrdB      = 0;
end

end
