const buttonYear = document.querySelector('#buttonAutoYear');

// Auto increment Year and get to back first year
function runAutoYear() {

    if (sliderYear.value != sliderYear.max) {
        sliderYear.value++;
        setYear();
    } else {
        sliderYear.value = sliderYear.min;
        setYear();
    }
}


// Setup button interval for increment and background color
function setOnOff(){
    if(buttonYear.value == "ON"){
        clearInterval(window.autoInterval);
        buttonYear.value = "OFF";
        buttonYear.style.backgroundColor = null;
        buttonYear.style.color = "#000000";
    }
    else{

        window.autoInterval = setInterval(runAutoYear,2000);
        buttonYear.value = "ON";
        buttonYear.style.backgroundColor = "#00cbff";
        buttonYear.style.color = "#ffffff";
    }
}

