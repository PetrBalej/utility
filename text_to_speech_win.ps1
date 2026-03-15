Add-Type -AssemblyName System.Speech
$voice = New-Object System.Speech.Synthesis.SpeechSynthesizer
$voice.SelectVoice("Microsoft David Desktop")
$voice.SetOutputToWaveFile("C:\OUTPUT_AUDIO.waw")
$text = Get-Content "C:\INPUT_TEXT.txt" -Raw
$