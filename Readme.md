iOS fork of AlephOne, the open source engine for Bungie's Marathon.

### Building

- Make a folder called `marathon-ios` (or whatever you want)
- Clone the project inside `marathon-ios`
- Go inside the cloned project and do `git submodule update --init`
- Rename the file `Secrets_dummy.h` to `Secrets.h` (unless you own the **real** `Secrets.h`)
- Step back to `marathon-ios`
- Make a folder called `CompiledScenarios` (has to be this name!)
- Inside `CompiledScenarios` do any or all of the following:
	`git clone git@github.com:Aleph-One-Marathon/data-marathon.git M1A1`
	`git clone git@github.com:Aleph-One-Marathon/data-marathon-2.git M2A1`
	`git clone git@github.com:Aleph-One-Marathon/data-marathon-infinity.git M3A1`
- Finally go back to where the Marathon sources are, open `AlephOne.xcodeproj` and build whichever scenario you have in `CompiledScenarios`

Enjoy!

