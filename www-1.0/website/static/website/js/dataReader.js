// Variables
var year2000 = new Array(), year2001 = new Array(), year2003 = new Array(), year2004 = new Array(), year2005 = new Array();
var year2006 = new Array(), year2007 = new Array(), year2008 = new Array(), year2009 = new Array(), year2010 = new Array();
var year2011 = new Array(), year2012 = new Array(), year2013 = new Array(), year2014 = new Array(), year2015 = new Array();
var year2016 = new Array(), year2002 = new Array(), reference = new Array();

var maxNumberInYear = new Array();
var minNumberInYear = new Array();

var maxYear;
var minYear;


//  Read Json
function getJson(url, callback){
    var xml = new XMLHttpRequest();
    xml.open('GET',url,true);
    xml.responseType = 'json';
    xml.onreadystatechange = function() {
        var status = xml.status;
        if (status === 200) {
            callback(null, xml.response);
        } else {
            callback(status, xml.response);
        }
    };
    xml.send();
}

// get location for JSON
function getUrl(){
    var url;
    if(getOptionMortalidade() == "Precoce"){
        if(getOption() == "Estado"){
            url = "static/website/json/estadoPrecoce.json";
        }
        else if(getOption() == "Microrregião"){
            url = "static/website/json/microrregiaoPrecoce.json";
        }
        else if(getOption() == "Munícipio"){
            url = "static/website/json/municipioPrecoce.json";
        }
    }
    else if(getOptionMortalidade() == "Tardia"){
        if(getOption() == "Estado"){
            url = "static/website/json/estadoTardia.json";
        }
        else if(getOption() == "Microrregião"){
            url = "static/website/json/microrregiaoTardia.json";
        }
        else if(getOption() == "Munícipio"){
            url = "static/website/json/municipioTardia.json";
        }
    }
    return url
}

// Put Json data in variables
function readJSON() {
    getJson(getUrl(), function (err, data) {
        if (err !== null) {
            console.log('Ocorreu um erro, codigo: ' + err);
        } else {
            if (data != null) {
                maxYear = data.maxYear;
                minYear = data.minYear;
                var numberCod;

                for (numberCod = 0; numberCod < data.maxAndMin.length; numberCod++) {
                    // get max Number in Year and min Number in Year
                    maxNumberInYear[numberCod] = data.maxAndMin[numberCod].max;
                    minNumberInYear[numberCod] = data.maxAndMin[numberCod].min;
                }

                // set number for States/Year
                for (numberCod = 0; numberCod < data.taxaMortalidade.length; numberCod++) {
                    // put data Number/Year
                    if(getOption() == "Microrregião"){
                        reference[numberCod] = data.taxaMortalidade[numberCod].codigo.toUpperCase();
                    }
                    else {
                        reference[numberCod] = data.taxaMortalidade[numberCod].codigo;
                    }
                    year2000[numberCod] = data.taxaMortalidade[numberCod].Y2000;
                    year2001[numberCod] = data.taxaMortalidade[numberCod].Y2001;
                    year2002[numberCod] = data.taxaMortalidade[numberCod].Y2002;
                    year2003[numberCod] = data.taxaMortalidade[numberCod].Y2003;
                    year2004[numberCod] = data.taxaMortalidade[numberCod].Y2004;
                    year2005[numberCod] = data.taxaMortalidade[numberCod].Y2005;
                    year2006[numberCod] = data.taxaMortalidade[numberCod].Y2006;
                    year2007[numberCod] = data.taxaMortalidade[numberCod].Y2007;
                    year2008[numberCod] = data.taxaMortalidade[numberCod].Y2008;
                    year2009[numberCod] = data.taxaMortalidade[numberCod].Y2009;
                    year2010[numberCod] = data.taxaMortalidade[numberCod].Y2010;
                    year2011[numberCod] = data.taxaMortalidade[numberCod].Y2011;
                    year2012[numberCod] = data.taxaMortalidade[numberCod].Y2012;
                    year2013[numberCod] = data.taxaMortalidade[numberCod].Y2013;
                    year2014[numberCod] = data.taxaMortalidade[numberCod].Y2014;
                    year2015[numberCod] = data.taxaMortalidade[numberCod].Y2015;
                    year2016[numberCod] = data.taxaMortalidade[numberCod].Y2016;
                }
                setRangeYear(maxYear, minYear);
            }
        }
    });
}

// get number for year in the map
function getNumberForJSON(d){
    var valueSlider = sliderYear.value;
    var number = null;
    var numberCodigo = 0;
    for(var numberCod = 0; numberCod < reference.length; numberCod++) {
        if(d == reference[numberCod]){
            numberCodigo = numberCod;
        }
    }

    if(valueSlider == 2000){
        number = year2000[numberCodigo];
    }
    else if(valueSlider == 2001){
        number = year2001[numberCodigo];
    }
    else if(valueSlider == 2002){
        number = year2002[numberCodigo];
    }
    else if(valueSlider == 2003){
        number = year2003[numberCodigo];
    }
    else if(valueSlider == 2004){
        number = year2004[numberCodigo];
    }
    else if(valueSlider == 2005){
        number = year2005[numberCodigo];
    }
    else if(valueSlider == 2006){
        number = year2006[numberCodigo];
    }
    else if(valueSlider == 2007){
        number = year2007[numberCodigo];
    }
    else if(valueSlider == 2008){
        number = year2008[numberCodigo];
    }
    else if(valueSlider == 2009){
        number = year2009[numberCodigo];
    }
    else if(valueSlider == 2010){
        number = year2010[numberCodigo];
    }
    else if(valueSlider == 2011){
        number = year2011[numberCodigo];
    }
    else if(valueSlider == 2012){
        number = year2012[numberCodigo];
    }
    else if(valueSlider == 2013){
        number = year2013[numberCodigo];
    }
    else if(valueSlider == 2014){
        number = year2014[numberCodigo];
    }
    else if(valueSlider == 2015){
        number = year2015[numberCodigo];
    }
    else if(valueSlider == 2016){
        number = year2016[numberCodigo];
    }

    if(number == "-"){
        return 0;
    }
    else {
        return number;
    }
}