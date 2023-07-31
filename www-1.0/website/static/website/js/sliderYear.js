const sliderYear = document.querySelector('#sliderYear');
const span = document.querySelector('#valYear');
const spanMaxYear = document.querySelector('#maxYear');
const spanMinYear = document.querySelector('#minYear');

function setYear() {
    // set valueSlider in span
    span.innerHTML = sliderYear.value;

    // set max and min in slider gradient
    if((maxNumberInYear[sliderYear.value - sliderYear.min] === (sliderYear.min - sliderYear.min) && minNumberInYear[sliderYear.value - sliderYear.min] === (sliderYear.max - sliderYear.min))
        || (minNumberInYear[sliderYear.value - sliderYear.min] == null || maxNumberInYear[sliderYear.value - sliderYear.min] == null)) {
        setLimitGradient("Sem dados", "Sem dados");
    }
    else if(minNumberInYear[sliderYear.value - sliderYear.min] === "-" || minNumberInYear[sliderYear.value - sliderYear.min] === "#VALOR!"){
        setLimitGradient(0,maxNumberInYear[sliderYear.value - sliderYear.min]);
    }
    else{
        if(minNumberInYear[sliderYear.value - sliderYear.min] === maxNumberInYear[sliderYear.value - sliderYear.min]){
            if(maxNumberInYear[sliderYear.value - sliderYear.min] === 0){
                setLimitGradient(minNumberInYear[sliderYear.value - sliderYear.min], "Sem dados")
            }
            else {
                setLimitGradient(minNumberInYear[sliderYear.value - sliderYear.min] - 1, maxNumberInYear[sliderYear.value - sliderYear.min]);
            }
        }
        else {
            setLimitGradient(minNumberInYear[sliderYear.value - sliderYear.min], maxNumberInYear[sliderYear.value - sliderYear.min]);
        }
    }

    // wait time to color map
    window.setTimeout(setColorMap,100);
    loadData(codigoVisualizacao);
}

// set range in the slider Year
function setRangeYear(maxYear, minYear) {
    sliderYear.min = minYear;
    sliderYear.max = maxYear;
    spanMaxYear.innerHTML = sliderYear.max;
    spanMinYear.innerHTML = sliderYear.min;
    setYear();
}