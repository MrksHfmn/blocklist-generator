# Blocklist Generator

The Blocklist Generator generates a large blocklist from many blocklists and throws out all entries that are already removed by regex rules

## Installation

Make sure curl is installed.

```sh
$ git clone https://github.com/MrksHfmn/blocklist-generator.git
$ cd blocklist-generator
$ ./generator.sh
```

## Adjustments

You're probably gonna have to make some changes:

- *list.txt*: Contains all block lists. Good lists can be found here:
    - https://firebog.net/
    - https://www.github.developerdan.com/hosts/
    - lists_big.txt contains a large number of blocklists


- *regex.txt*: In this file all regex rules are collected. after all lists are downloaded, all entries already filtered by the built-in regex filters in Pi-Hole or AdGuardHome are ejected. Good Regex rules can be found here:
    - For AdGuardHome: https://github.com/mmotti/adguard-home-filters/blob/master/regex.txt
    - For Pi-Hole: https://github.com/mmotti/pihole-regex/blob/master/regex.list
    - This file has to be added to AdGuardHome or each entry must be added in Pi-Hole.


- *custom_blacklist.txt*: Pages you want to add to the big blocklist
- *custom_whitelist.txt*:  Pages you want to remove from the big blocklist



