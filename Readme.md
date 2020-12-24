iOS fork of AlephOne, the open source engine for Bungie's Marathon.

### Building

1. Make a folder called `marathon-ios` (or whatever you want)
2. Clone the project this repo inside `marathon-ios`
3. Go inside the cloned project and do `git submodule update --init`
4. Step back to `marathon-ios`
5. Make a folder called `CompiledScenarios` (has to be this name!)
6. Inside `CompiledScenarios` do any or all of the following:
	`git clone git@github.com:Aleph-One-Marathon/data-marathon.git M1A1`
	`git clone git@github.com:Aleph-One-Marathon/data-marathon-2.git M2A1`
	`git clone git@github.com:Aleph-One-Marathon/data-marathon-infinity.git M3A1`
7. Finally go back to where the Marathon sources are, open `AlephOne.xcodeproj` and build whichever scenario you have in `CompiledScenarios`

Enjoy!

