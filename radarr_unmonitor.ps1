$expected_eventtype='Download'
$search_text_1='lama'

('{0} - In event '''+$env:radarr_eventtype+''' for movie file '''+$env:radarr_moviefile_relativepath+'''') -f (Get-Date) | Out-File -FilePath C:\radarr_unmonitor.txt -Append

if ($env:radarr_eventtype -eq $expected_eventtype)
{
  ('{0} - In expected if statement') -f (Get-Date) | Out-File -FilePath C:\radarr_unmonitor.txt -Append

  if ($env:radarr_moviefile_relativepath -like ('*{0}*' -f [WildcardPattern]::Escape($search_text_1)))
  {
    ('{0} - Search text '''+$search_text_1+''' found') -f (Get-Date) | Out-File -FilePath C:\radarr_unmonitor.txt -Append

    $headers=@{}
    $headers.Add("accept", "*/*")
    $headers.Add("X-Api-Key", "")
    $headers.Add("Content-Type", "application/json")
    $body='{{
      "movieIds": [
        {0}
      ],
      "monitored": false
    }}' -f $env:radarr_movie_id
    
    $response = Invoke-WebRequest -Uri 'http://localhost:7878/api/v3/movie/editor' -Method PUT -Headers $headers -ContentType 'application/json' -Body $body

    ('{0} - Completed request') -f (Get-Date) | Out-File -FilePath C:\radarr_unmonitor.txt -Append
  }
}