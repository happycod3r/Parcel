#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'

out "
${NC}To encrypt and create an archive do:
    ${RED}parcel myfile.txt myfolder${NC}
To decrypt and extract an archive/s do:
    ${RED}parcel -x${NC} | ${RED}parcel --extract${NC}
To delete an archive/s do:
    ${RED}parcel -d${NC} | ${RED}parcel --delete${NC}
To import .parcel archives do:
    ${RED}parcel -i${NC} | ${RED}parcel --import${NC}
To view this message do:
    ${RED}parcel -h${NC} | ${RED}parcel --help${NC}
For parcels current version do:
    ${RED}parcel -v${NC} | ${RED}parcel --version${NC}
For parcels install location do:
    ${RED}parcel -l${NC} | ${RED}parcel --get-location${NC}
To uninstall Parcel do:
    ${RED}parcel -u${NC} | ${RED}parcel --uninstall${NC}

for more information check out the README @ https://github.com/happycod3r/parcel
"
#[xdvhluic]
