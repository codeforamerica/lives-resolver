# LIVES Resolver 

## Wat?

This is a simple Ruby utility to resolve businesses entities in the LIVES restaurant inspections data standard against the Factual API, storing the results in a Mongo data store.

### Current Status

Lives-Resolver's current development state is: **SCRIPT-HACKY**

Presently, the script was using as an input file something slightly off-spec for LIVES, so it is being modified accordingly. The basic structure should not change, but consider yourself forewarned.

## Installing

### Requirements

* Ruby (developed on 1.9.3)
* Gems listed in Gemfile (see Getting Started)
* MongoDB

### Getting Started

As noted above, this is super scripty right now, so will require some effort to make use of it. The key pieces are:

* Set up MongoDB instance with appropriate credentials
* Get a Factual API key and add it to your environment variables (there are restrictions on this API, so if you want to do bulk processing, you would need special permissions; if interested in collaborating with CFA on this, contact us via Issues or Twitter)
* Pull in your own city's LIVES `businesses.csv` file and modify the script as necessary (as mentioned above, will require changes to script presently)

That said, in all honesty the best way to use this is to contact us, and we'll connect and get you set up with less hassle.

## Contributing

If you're interested in the broader restaurant inspections data project, it's best to discuss it on [GitHub Issues](https://github.com/codeforamerica/lives-resolver/issues) or ping [@allafarce](https://twitter.com/allafarce) on Twitter.

## License and Copyright

Copyright 2013 Code for America Laboratories

Open source under the BSD license (see LICENSE.md for full details)

