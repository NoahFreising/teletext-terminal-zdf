# ZDF Teletext CLI utility

## General

As the name says, you can access the teletext of the german tv channel ZDF with this script. I wrote it inspired by [teletext-terminal-ard](https://github.com/AdamSchrey/teletext-terminal-ard). 

## How to run

Make sure you have a current version of ruby installed. I used [nokogiri](https://nokogiri.org/) for parsing the html. [Formatador](https://github.com/geemus/formatador) is used for some nicer tables. Install them:

```bash
gem install nokogiri
gem install formatador
```

Run the application:

```bash
ruby zdf_teletext.rb
```