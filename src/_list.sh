#!/bin/bash

function _list() {
    out "All existing .parcel archives:"

    ls -alh Parcels/
}

_list
