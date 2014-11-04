## Synopsis

The "Rename For Web" OS X Automator service provides a quick and easy way to rename a selected number of files, in a web-friendly sort of way, from the context menu in the Finder. It makes all characters ascii, lowercase, deviod of punctuation and substitues dashes for spaces. This service is aimed at non-technical clients and friends and family running Mac OS X.


## Installation and use

Email the desired workflow file to your client, friend and/or family member. Instruct them to double-click the  file and choose "install" from the dialog box. Once installed the user can select files in the Finder, right-click and choose "Rename For Web" from the context menu.

### Screencast How-To

[![View screencast on YouTube](http://img.youtube.com/vi/m6WQbB0SvME/0.jpg)](http://www.youtube.com/watch?v=m6WQbB0SvME)

## TODO

Optimise for Yosemite.

Better determine duplicate files instead of incrementing all. Duplicate files with different names can be checked with ```cmp``` and a dailog can be displayed to user as to whether to keep only one.

Possibly create a service that recursively renames a hierarchy of directories and files. Maybe a little to dangerous?

## Contributors

Accepting pull requests and issues via [GitHub](https://github.com/joebushi/rename-for-web).

## License

Rename For Web is released under the [MIT License](http://www.opensource.org/licenses/MIT).