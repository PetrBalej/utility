Add-Type -AssemblyName System.Speech
$voice = New-Object System.Speech.Synthesis.SpeechSynthesizer
$voice.SelectVoice("Microsoft David Desktop")
$voice.SetOutputToWaveFile("C:\OUTPUT_AUDIO.wav")
$text = Get-Content "C:\INPUT_TEXT.txt" -Raw
$voice.Speak($text)
$voice.Dispose()
