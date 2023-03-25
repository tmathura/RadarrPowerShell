$expected_eventtype = 'Download'
$search_text_1 = 'lama'
$search_text_2 = 'rarbg'
$search__sub_text_2 = '265'
$search_text_3 = 'psa'
$doApiCall = $false;

#$env:radarr_eventtype = 'Download'
#$env:radarr_moviefile_relativepath = 'Cloverfield.2008.1080p.BluRay.x265-LAMA.mp4'
#$env:radarr_movie_id = 1821

('{0} - In event ''' + $env:radarr_eventtype + ''' for movie file ''' + $env:radarr_moviefile_relativepath + '''') -f (Get-Date) | Out-File -FilePath C:\radarr_unmonitor.txt -Append

if ($env:radarr_eventtype -eq $expected_eventtype) {
  ('{0} - In expected if statement') -f (Get-Date) | Out-File -FilePath C:\radarr_unmonitor.txt -Append

  if ($env:radarr_moviefile_relativepath -like ('*{0}*' -f [WildcardPattern]::Escape($search_text_1))) {
    ('{0} - Search text 1 ''' + $search_text_1 + ''' found') -f (Get-Date) | Out-File -FilePath C:\radarr_unmonitor.txt -Append
    $doApiCall = $true;
  }

  if ($env:radarr_moviefile_relativepath -like ('*{0}*' -f [WildcardPattern]::Escape($search_text_3))) {
    ('{0} - Search text 1 ''' + $search_text_3 + ''' found') -f (Get-Date) | Out-File -FilePath C:\radarr_unmonitor.txt -Append
    $doApiCall = $true;
  }

  if ($env:radarr_moviefile_relativepath -like ('*{0}*' -f [WildcardPattern]::Escape($search_text_2)) -And $env:radarr_moviefile_relativepath -like ('*{0}*' -f [WildcardPattern]::Escape($search__sub_text_2))) {
    ('{0} - Search text 2 ''' + $search_text_2 + ''' found') -f (Get-Date) | Out-File -FilePath C:\radarr_unmonitor.txt -Append
    $doApiCall = $true;
  }

  if ($doApiCall) {
    ('{0} - Initiate API call') -f (Get-Date) | Out-File -FilePath C:\radarr_unmonitor.txt -Append

    $headers = @{}
    $headers.Add("accept", "*/*")
    $headers.Add("X-Api-Key", "")
    $headers.Add("Content-Type", "application/json")
    $body = '{{
      "movieIds": [
        {0}
      ],
      "monitored": false
    }}' -f $env:radarr_movie_id
    
    $response = Invoke-WebRequest -Uri 'http://localhost:7878/api/v3/movie/editor' -Method PUT -Headers $headers -ContentType 'application/json' -Body $body

    ('{0} - Completed API call') -f (Get-Date) | Out-File -FilePath C:\radarr_unmonitor.txt -Append
  }
  else {
    ('{0} - API not called') -f (Get-Date) | Out-File -FilePath C:\radarr_unmonitor.txt -Append
  }
}