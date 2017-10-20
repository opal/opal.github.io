# Opal Website

This repo holds the source of the opalrb.com website.

## Preparing

Clone this repo, and use bundler to get dependencies:

    $ bin/setup

The website is built using middleman. It also incorporates the awesome awesome-opal list by @fazibear.
To update the list just run

    $ bin/update-libraries-page

## Run site/server

    $ bin/server

Then visit `http://localhost:4567`.

## Publishing

    $ bin/deploy

