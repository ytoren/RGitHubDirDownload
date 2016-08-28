# RGitHubDirDownload
A set of functions to list &amp; download entire directories from GitHub data sources (using only web protocols, no need to install git)

## Installing

Just clone from GitHub or download the R file, then load the function with

``` 
source("C:\\somepath\\RGitHubDirDownload.R")
```

### Dependencies 

The function requires the [httr](https://cran.r-project.org/web/packages/httr/index.html) package.
The function will check for the presence of the required packages and will return specific error message if they are not installed.

## Usage
```GitHubDirDownload(git_user, git_repo, ... )```

## Arguments

parameter| Description
---------|------------
```git_user``` | GitHub username
```git_repo``` | GitHub reposetory name
```git_dir = NULL```| GitHub subdir. Defaults to root directory. If specified must end with a '/'
```output_dir = './'``` | Where should the files be stored? defaults to getwd(). If specified must end with a '/'
```pattern = NULL``` | grep pattern to select specific files, e.g. 'csv$'. NULL means all files in the directory
```git_website_url_base = 'https://github.com/'``` | Download link components^\*^
```git_api_url_base = 'https://api.github.com/repos/'``` | Download link components^\*^
```git_api_url_suffix = 'git/refs/'``` | Download link components^\*^
```git_api_texts = 'raw/master/'``` | Download link components^\*^
```parse_csv = NULL``` |   function to convert the files into data.frames. NULL triggers dumping of files into separate files.
```return_df = FALSE``` | special treatment for CSV files: write each file or return a list containing all files.
```append_files = TRUE``` | special treatment for CSV files: Should we try to append all files into a single DF?
```...``` | additional aguments for parse_csv: ```sep = ','```, ```row.names = FALSE``` etc.

^\*^ if the GitHub API changes these should be modified (updated Aug-2016)

## Value
Depending on the value of ```return_df```:

* ```FALSE```: the function can write a single / multiple files to ```output_dir``` and return ```NULL```
* ```TRUE```: the function will return a single ```data.frame``` (```append_files = TRUE```) or a ```list``` with multiple entries. 

## Authors
Yizhar (Izzie) Toren

## License
This project is licensed under the Apache v2.0 License - see the [LICENSE](https://github.com/ytoren/RGitHubDirDownload/blob/master/LICENSE) file for details.

## Acknowledgments
* Parsing GitHub directories from XML from this StackOverflow [post](http://stackoverflow.com/questions/25485216/how-to-get-list-files-from-a-github-repository-folder-using-r).



