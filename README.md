<div id="top"></div>

<br />
<div align="center">

  <h1 align="center"><img src="https://i.imgur.com/efWK1Rc.png"></h1>

  <p align="center">
    A player property resource for FiveM.
    <br />
    <a href="https://github.com/borisnliscool/bnl-housing/issues">Report a Bug</a>
    ·
    <a href="https://github.com/borisnliscool/bnl-housing/issues">Request a Feature</a>
    ·
    <a href="https://borisnl.nl/discord">Join my Discord</a>
  </p>
</div>

## About The Project

A player property resource that allows you to purchase, sell, decorate, store your vehicles, and *much* more. This script is *currently* standalone and does *not* require a framework. In the future I am however planning on adding support for the major frameworks.

If you're looking for the docs or commands you can find them [here](https://github.com/borisnliscool/bnl-housing/blob/main/DOCS.md) (for now)

<img src="https://user-images.githubusercontent.com/60477582/171034076-a15f0d8e-8216-487e-a51a-e01322c316c7.png">

## Dependencies

1. [ox_lib](https://github.com/overextended/ox_lib)
2. [oxmysql](https://github.com/overextended/oxmysql)
3. baseevents

## Installation

- Be sure to download the [latest release](https://github.com/borisnliscool/bnl-housing/releases) of the resource, it's always good to stay up to date.
- Place it somewhere inside the `resources` directory
- Add the resource to your `server.cfg` after dependencies to make sure it's started correctly at server startup:
```
ensure bnl-housing
```
- Lastly, insert `bnl_housing.sql` into your database.

If you incounter any issues downloading, you can ask for help in [my discord](https://borisnl.nl/discord).

<p align="right">(<a href="#top">back to top</a>)</p>

<img src="https://user-images.githubusercontent.com/60477582/171034076-a15f0d8e-8216-487e-a51a-e01322c316c7.png">

## Roadmap

- [x] Ownable properties
- [x] Share keys
  - [x] Give spare keys to players
  - [x] Take spare keys from players 
- [x] Invite players inside
- [x] Knock on doors of properties
- [x] Locale support
  - [x] Dutch (NL)
  - [x] English (EN)
  - [x] French (FR)
- [x] Logging out in properties
- [ ] Decorate properties
  - [ ] Normal props
  - [x] Special props that do things when near like a storage container or laptop
    - [x] Safe with codelock
    - [x] Example prop
  - [x] Add qTarget support for special props
- [ ] Park vehicles in garages or warehouses
  - [x] Enter properties with vehicles
  - [x] Save them
  - [x] Idea: Max vehicle count per shell
  - [x] Passengers enter property
  - [ ] Check for space before enter
- [ ] Break in / lockpick
- [ ] Unlock property so anyone is free to enter
- [ ] Code lock option for front door
- [ ] Police raid
- [ ] Property selling
  - [ ] Rent out property
- [ ] Realtor job
- [ ] Property blips
  - [x] Working
  - [x] Improve performance
    - [ ] Make it even better
  - [x] Correct Sprite for different property types

<p align="right">(<a href="#top">back to top</a>)</p>

<img src="https://user-images.githubusercontent.com/60477582/171034076-a15f0d8e-8216-487e-a51a-e01322c316c7.png">

## License

Distributed under the GPL-3.0 License. See [LICENSE](https://github.com/borisnliscool/bnl-housing/blob/main/LICENSE) for more information.

<p align="right">(<a href="#top">back to top</a>)</p>


## Contact

[Boris NL#1500](https://borisnl.nl/discord) - [@borisnlyt](https://twitter.com/borisnlyt) - [boris@borisnl.nl](mailto:boris@borisnl.nl)

Project Link: [https://github.com/borisnliscool/bnl-housing](https://github.com/borisnliscool/bnl-housing)

<p align="right">(<a href="#top">back to top</a>)</p>

## Acknowledgments

Thanks to all contributors and testers especially [@CasperV06](https://github.com/CasperV06) & [@pimiscool](https://github.com/pimiscool) for helping me test.
