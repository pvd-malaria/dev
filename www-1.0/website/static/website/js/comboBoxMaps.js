var comboBoxMap = document.getElementById("comboBoxMap");

function getOption(){
    if(comboBoxMap.value == "state"){
        return "Estado";
    }
    else if(comboBoxMap.value == "microregion"){
        return "Microrregião";
    }
    else if(comboBoxMap.value == "county"){
        return "Munícipio";
    }
}