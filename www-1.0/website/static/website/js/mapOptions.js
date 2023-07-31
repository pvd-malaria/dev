// Switch Map and remove after map
function switchMap() {
    d3.selectAll("g > *").remove();
    d3.selectAll("path > *").remove();
    d3.selectAll("map > *").remove();

    if(getOption() == "Estado"){
        showStateMap();
        readJSON();
    }
    else if(getOption() == "Microrregião"){
        showMicroregionMap();
        readJSON();
    }
    else if(getOption() == "Munícipio"){
        showCountyMap();
        readJSON();
    }
}

// Set color in Map
function setColorMap() {
    if(getOption() == "Estado"){
        colorState();
    }
    else if(getOption() == "Microrregião"){
        colorMicrorregion();
    }
    else if(getOption() == "Munícipio"){
        colorCounty();
    }
}

// function to get color for state in the year
function getColor(value){
    var number = getNumberForJSON(value);
    return getColorGradient(number);
}

// Formart County
function formatCounty(county) {
    return county.substring(0,county.length-1);
}

// get number of state
function getNumberState(state) {
    if(state == "AC"){
        return 12;
    }
    else if(state == "AL"){
        return 27;
    }
    else if(state == "AP"){
        return 16;
    }
    else if(state == "AM"){
        return 13;
    }
    else if(state == "BA"){
        return 29;
    }
    else if(state == "CE"){
        return 23;
    }
    else if(state == "DF"){
        return 53;
    }
    else if(state == "ES"){
        return 32;
    }
    else if(state == "GO"){
        return 52;
    }
    else if(state == "MA"){
        return 21;
    }
    else if(state == "MT"){
        return 51;
    }
    else if(state == "MS"){
        return 50;
    }
    else if(state == "MG"){
        return 31;
    }
    else if(state == "PA"){
        return 15;
    }
    else if(state == "PB"){
        return 25;
    }
    else if(state == "PR"){
        return 41;
    }
    else if(state == "PE"){
        return 26;
    }
    else if(state == "PI"){
        return 22;
    }
    else if(state == "RJ"){
        return 33;
    }
    else if(state == "RN"){
        return 24;
    }
    else if(state == "RS"){
        return 43;
    }
    else if(state == "RO"){
        return 11;
    }
    else if(state == "RR"){
        return 14;
    }
    else if(state == "SC"){
        return 42;
    }
    else if(state == "SP"){
        return 35;
    }
    else if(state == "SE"){
        return 28;
    }
    else if(state == "TO"){
        return 17;
    }
}