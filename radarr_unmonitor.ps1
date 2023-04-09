$expected_eventtype = 'Download'
$release_groups = @('lama', 'rarbg', 'psa')
$qualities = @('265')
$release_groups_optional = @('yify')
$qualities_optional = @('264')
$doApiCall = $false;
$log_file = ('{0}\raddarr_powershell.log') -f ($PSScriptRoot)

#$env:radarr_eventtype = 'Download'
#$env:radarr_moviefile_relativepath = 'Cloverfield.2008.1080p.BluRay.x265-LAMA.mp4'
#$env:radarr_movie_id = 1821

('{0} - In event ''' + $env:radarr_eventtype + ''' for movie file ''' + $env:radarr_moviefile_relativepath + '''') -f (Get-Date) | Out-File -FilePath $log_file -Append

if ($env:radarr_eventtype -eq $expected_eventtype) {
  ('{0} - In expected event ''' + $expected_eventtype + '''') -f (Get-Date) | Out-File -FilePath $log_file -Append

  for ( $release_group = 0; $release_group -lt $release_groups.count; $release_group++) {
    for ( $quality = 0; $quality -lt $qualities.count; $quality++) {
      if ($env:radarr_moviefile_relativepath -like ('*{0}*' -f [WildcardPattern]::Escape($release_groups[$release_group])) -And $env:radarr_moviefile_relativepath -like ('*{0}*' -f [WildcardPattern]::Escape($qualities[$quality]))) {
        ('{0} - Release group ''' + $release_groups[$release_group] + ''' found') -f (Get-Date) | Out-File -FilePath $log_file -Append
        $doApiCall = $true;
      }
    }
  }

  for ( $release_group_optional = 0; $release_group_optional -lt $release_groups_optional.count; $release_group_optional++) {
    for ( $quality_optional = 0; $quality_optional -lt $qualities_optional.count; $quality_optional++) {
      if ($env:radarr_moviefile_relativepath -like ('*{0}*' -f [WildcardPattern]::Escape($release_groups_optional[$release_group_optional])) -And $env:radarr_moviefile_relativepath -like ('*{0}*' -f [WildcardPattern]::Escape($qualities_optional[$quality_optional]))) {
        ('{0} - Release group optional ''' + $release_groups_optional[$release_group_optional] + ''' found') -f (Get-Date) | Out-File -FilePath $log_file -Append
        $doApiCall = $true;
      }
    }
  }

  if ($doApiCall) {
    ('{0} - Initiate API call') -f (Get-Date) | Out-File -FilePath $log_file -Append

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

    ('{0} - Completed API call') -f (Get-Date) | Out-File -FilePath $log_file -Append
  }
  else {
    ('{0} - API not called') -f (Get-Date) | Out-File -FilePath $log_file -Append
  }
}