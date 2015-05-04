close all 
% first you have to initialize the additional toolbox that allows for
% simultaneous realtime recording and playback


%% Initialization
   InitializePsychSound

%search for audio playback and recording devices
   devices = PsychPortAudio('GetDevices' );
   
   
   %%
%select the connected device
   dev =   3;

%set the sampling rate to be used
   fs  =   96000;

%set the length of the test-signal to be used
   sig_len = 20;


% The following code will produce a sine-sweep.

   fs1 =   1;
   fs2 =   fs./2;
   %fs2 = 5000;

   T   =   sig_len;
% Create the swept sine tone
   w1  =   2*pi*fs1;
   w2  =   2*pi*fs2;
   K   =   T*w1/log(w2/w1); %MATLAB notation: log(x)==ln(x)
   L   =   T/log(w2/w1);
   t   =   linspace(0,T-1/fs,fs*T);
   sweep   =   sin(K*(exp(t/L) - 1));
   
   f0 = 3000 ;
   f1 = 4000 ;
   endTime = 20;
   sine= 0.5*sin(2*pi*f0/fs.*(1:endTime*fs)');
   sine2= 0.5*sin(2*pi*f1/fs.*(1:endTime*fs)');

   sine = sine' ;
   sine2= sine2';
   %%% THIS ONE IS IMPORTANT! IT SET BASICALLY THE VOLUME!!!
   % Do NOT GO TOO HIGH!!! WITH THE MOTU, YOU CANNOT CHANGE THE VOLUME FOR
   % THE OUTPUTS VIA SYSTEM-VOLUME OR SOMETHING LIKE THAT!!!!
   output_sweep        =   0.50*sweep;
   %output_sweep        =   0.0.*sweep;
    

%%%% end of seep-generation %%%%

% the following code manages the playback and recording.
% For reference, please see the psychportaudio online-help

% from online help:
% pahandle = PsychPortAudio('Open' [, deviceid][, mode][,
% reqlatencyclass][, freq][, channels][, buffersize][, suggestedLatency][, selectchannels][, specialFlags=0]);
%
% mode 3 == full duplex
% reqlatencyclass 3 == most aggressive for audio device
% AFTER FS: [1,5] defines: 1 output, 5 inputs
   
   
   minimumAmountOfDataSec= frameSize/fs ; 
   i=1 ;
   bufferSize = 1 ;
   frameSizeSeconds = 0.5 ;
   frameSize = frameSizeSeconds*fs;
   pahandle    =   PsychPortAudio('Open', dev, 3,3,fs,[1 1],[],[],[],1);
   PsychPortAudio('FillBuffer', pahandle, sine(1:fs/2));
   PsychPortAudio('GetAudioData', pahandle ,bufferSize);
   PsychPortAudio('Start', pahandle, [],[],[1],[],[]);
   %status = PsychPortAudio('GetStatus', pahandle);
    
   completeSignal = 0 ;
   tic
   while(toc< 15)
     [signal]    =   PsychPortAudio('GetAudioData', pahandle ,[],[frameSizeSeconds],[frameSizeSeconds],[]);
     completeSignal = [completeSignal,signal] ;
     [STFT1,F1,T1] = spectrogram(signal,frameSize,frameSize/2,frameSize,fs);
      imagesc(T1,F1,log10(abs(STFT1)))
     drawnow
     PsychPortAudio('FillBuffer', pahandle, sine2(1:fs/2),[1],[]);

    % WaitSecs(frameSizeSeconds)
   end
%    PsychPortAudio('Stop', pahandle);
%     [signal]    =   PsychPortAudio('GetAudioData', pahandle ,[],[],[]);
    PsychPortAudio('Close');
%     signal      =   signal';


% IR = [];
%    for ind = 1:size(signal,2)
% % In the following, the deconvolution procedure
% 
%    len =   length(output_sweep);
%    %IR  =   zeros(len,1);
% 
%    Y   = fft(signal(:,ind),(length(signal)+size(output_sweep,2)-1));
%    H   = fft(output_sweep',(length(signal)+size(output_sweep,2)-1));
%    G   =   Y./(H);
% 
% % => impulse response
%    IR_tmp  =   ifft(G);
%    IR(:,ind) = IR_tmp(1:floor(sig_len.*fs));
%    
%    % plot Room implulse reponse 
%    
%    end
%    
%    figure ;
%    stem(IR(:,ind));
   
   
%    figure; 
%    plot(output_sweep)
%    hold on 
%    plot(signal(:,1))