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
    <a href="https://boris.foo">Join my Discord</a>
  </p>
</div>

## About The Project

A player property resource that allows you to purchase, sell, decorate, store your vehicles, and more. This script is currently standalone and does not require a framework. However in the future I'm planning on adding support for the major frameworks.

_If you're looking for the docs or commands you can find them [here](https://github.com/borisnliscool/bnl-housing/blob/main/DOCS.md)._

<img src="https://user-images.githubusercontent.com/60477582/171034076-a15f0d8e-8216-487e-a51a-e01322c316c7.png">

## Dependencies

1. [ox_lib](https://github.com/overextended/ox_lib)
2. [oxmysql](https://github.com/overextended/oxmysql)

## Installation

- Be sure to download the [latest release](https://github.com/borisnliscool/bnl-housing/releases) of the resource, it's always good to stay up to date.
- Place it somewhere inside the `resources` directory
- Add the resource to your `server.cfg` after dependencies to make sure it's started correctly at server startup:<br>
  `ensure bnl-housing`
- Lastly, insert `bnl_housing.sql` into your database.

If you incounter any issues downloading, you can ask for help in [my discord](https://boris.foo/discord).

<p align="right">(<a href="#top">back to top</a>)</p>

<img src="https://user-images.githubusercontent.com/60477582/171034076-a15f0d8e-8216-487e-a51a-e01322c316c7.png">

<br>

## FAQ

1. Where can I get the property shells?<br>
   [here](https://mega.nz/file/G01QxIJL#ctLH4cz46Kqyo8V2dTCCSMYS6ii1GB85qXX1LYt34Wg)

2. How can I give myself admin perms?<br>
   To give yourself `"bnl-housing:admin"` permission, you need to add it to your Ace permissions in the server.cfg file. Open the file and add the following line: `add_principal identifier.steam:[your steam id] "bnl-housing:admin" allow`, replacing [your steam id] with your actual Steam ID.

   Alternatively, if you have an admin group you can add the ace to that: `add_ace group.admin "bnl-housing:admin" allow`

<p align="right">(<a href="#top">back to top</a>)</p>

<img src="https://user-images.githubusercontent.com/60477582/171034076-a15f0d8e-8216-487e-a51a-e01322c316c7.png">

<br>

## License

Distributed under the GPL-3.0 License. See [LICENSE](https://github.com/borisnliscool/bnl-housing/blob/main/LICENSE) for more information.

## Acknowledgments

Thanks to all contributors and testers, especially [@CasperV06](https://github.com/CasperV06) & [@pimiscool](https://github.com/pimiscool).

<p align="right">(<a href="#top">back to top</a>)</p>
