var comboBoxTaxa = document.getElementById("comboBoxTaxaMortalidade");

function getOptionMortalidade(){
    if(comboBoxTaxa.value == "Precoce"){
        return "Precoce";
    }
    else if(comboBoxTaxa.value == "Tardia"){
        return "Tardia";
    }
}