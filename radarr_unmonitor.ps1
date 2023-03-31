$expected_eventtype = 'Download'
$release_groups = @('lama','rarbg','psa')
$quality = '265'
$doApiCall = $false;

#$env:radarr_eventtype = 'Download'
#$env:radarr_moviefile_relativepath = 'Cloverfield.2008.1080p.BluRay.x265-LAMA.mp4'
#$env:radarr_movie_id = 1821

('{0} - In event ''' + $env:radarr_eventtype + ''' for movie file ''' + $env:radarr_moviefile_relativepath + '''') -f (Get-Date) | Out-File -FilePath C:\radarr_unmonitor.txt -Append

if ($env:radarr_eventtype -eq $expected_eventtype) {
  ('{0} - In expected event ''' + $expected_eventtype + '''') -f (Get-Date) | Out-File -FilePath C:\radarr_unmonitor.txt -Append

  for ( $index = 0; $index -lt $release_groups.count; $index++)
  {
      if ($env:radarr_moviefile_relativepath -like ('*{0}*' -f [WildcardPattern]::Escape($release_groups[$index])) -And $env:radarr_moviefile_relativepath -like ('*{0}*' -f [WildcardPattern]::Escape($quality))) {
        ('{0} - Release group ''' + $release_groups[$index] + ''' found') -f (Get-Date) | Out-File -FilePath C:\radarr_unmonitor.txt -Append
        $doApiCall = $true;
      }
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