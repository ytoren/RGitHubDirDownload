# A function to download multiple files from a GitHub data repository directory. depends on <httr> library. 
# Subdir names are converted in to file prefixs
# Has special support for CSV fiels (e.g. appending to a single file)

GitHubDirDownload <- function (

  git_user, # GitHub username
  git_repo, # GitHub reposetory name
  git_dir = '/', # subdir. Defaults to root directory. must end with a '/'
  output_dir = './', # where should the files be stored?
  pattern = NULL, # grep pattern to select specific files, e.g. 'csv$'
  
  # Download link components - if the GitHub API changes these should be modified (updated Aug-2016)
  git_website_url_base = 'https://github.com/',
  git_api_url_base = 'https://api.github.com/repos/',
  git_api_url_suffix = 'git/refs/',
  git_api_texts = 'raw/master/',
  
  #function to convert the files into data.frames. NULL triggers dumping of files into separate files 
  parse_csv = read.csv, 
  # special treatment for CSV files: write each file or return a list containing all files. 
  return_df = FALSE,
  # special treatment for CSV files: Should we try to append all files into a single DF?
  append_files = TRUE,
  # additional aguments for parse_csv: sep = ',', row.names = FALSE,
  ...
  
) {
  
  # check is the 'httr' package is installed
  if(length(grep('^httr$', installed.packages(fields = 'Package'))) > 0) {

    require(httr)
    
  } else {

    stop('Please install httr package before proceeding')
  
  }

  # parse url's
  git_name <- paste(git_user, '/', git_repo, '/', sep = '')
  git_url_address <- paste(git_website_url_base, git_name, sep = '')
  git_url_api <- paste(git_api_url_base, git_name, git_api_url_suffix, sep = '')
  
  # GET file lists
  req <- GET(git_url_api)
  stop_for_status(req)
  req <- GET(content(req)[[1]]$object$url)
  stop_for_status(req)
  req <- GET(paste(content(req)$tree$url, 'recursive=1', sep = '?'))
  stop_for_status(req)
  
  # Parse dull directory listings of all files in the repository. 
  # solution source: http://stackoverflow.com/questions/25485216/how-to-get-list-files-from-a-github-repository-folder-using-r
  global_file_list <- unlist(lapply(content(req)$tree, "[", "path"), use.names = F)
  
  # Select only files form the directory
  all_files_in_dir <- grep(paste('^', git_dir, sep = ''), global_file_list, value = TRUE)
  
  # Clean up (both objects can be large)
  rm(req,global_file_list)
  
  # From the files in the directory, select only the ones that match <pattern>
  if (!is.null(pattern)) {

    download_file_list <- grep(pattern, all_files_in_dir, value = TRUE)

  } else {

    download_file_list <- all_files_in_dir
  
  }

  # Create links for download
  download_link_list <- paste(git_url_address, git_api_texts, download_file_list, sep = '')

  # Loop through files
  for (i in 1:length(download_link_list)) {
    
    # download each link & parse data into a connection
    request <- GET(download_link_list[i])
    stop_for_status(request)
    handle <- textConnection(content(request, as = 'text'))
    
    # write it out
    if (is.null(parse_csv)) {

      # If no parse_csv is specified, write "raw" files separately 
      write(x = content(request, as = 'text'), file = paste(output_dir, gsub(pattern = '/', '_', download_file_list[i]), sep = ''))
      
    } else {

      if (return_df) {

        if (append_files) {
          
          # For DF append we need to srart with NULL and continue with rbind (assumes identical data structure)
          if (i == 1) {df_agg <- NULL} # create aggregation variable
          df_agg <- rbind(df_agg, data.frame(filename = download_file_list[i],parse_csv(handle)))

        } else {

          # For a list of DF (no appending)
          if (i == 1) {df_agg <- list(parse_csv(handle))} else {df_agg[[i]] <- parse_csv(handle)}
          names(df_agg)[[i]] <- download_file_list[i]
          
        }
        
      } else {
        
        # parse filename(s) to write (one large or multiple single tables)
        file_name <- ifelse (
          append_files,
          paste(gsub(pattern = '/', '_', git_dir), '.csv', sep = ''),
          gsub(pattern = '/', '_', download_file_list[i])
        )
        
        # write it out
        write.table(
          x = data.frame(filename = download_file_list[i], parse_csv(handle)), 
          file = paste(output_dir, file_name, sep = ''), 
          sep = sep,
          row.names = row.names,
          append = (append_files & i > 1), 
          col.names = (i == 1 | !append_files), # write header only for first line or for each file
          ...
        )  
        
      }
      
    }

    # Clean up
    close(handle)
        
    # progress report
    cat(download_file_list[i]);cat('\n')
    
  }
  
  # return DF or NULL if only writing files
  return(if (return_df) df_agg else NULL)
  
}