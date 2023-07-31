// Slider of Numbers in Gradient

const sliderGradient = document.querySelector('#gradientSlider');
const spanMaxNumber = document.querySelector('#maxNumber');
const spanMinNumber = document.querySelector('#minNumber');

// set range disable
document.getElementById("gradientSlider").disabled = true;

// Take the color of the range according to the valueSlider
function getColorGradient(valor){
    const percent = (valor - sliderGradient.min) / (sliderGradient.max - sliderGradient.min);
    return switchColor(percent);
}

// returns the color according to the percentage
function switchColor(percent){
	var percentage;

	// gradient is three color, get the range
	if(percent >= 0 && percent <= 0.25) {

        // sets the color in a range from 0% to 100% again
		if(percent == 0) {
		  percentage = 0;
		}
		else{
		  percentage = ((percent * 1) / 0.25);
		}

		// return the mixed color
		return mixColor("#c2e5fd", "#75cce4", percentage);
	}
	else if(percent >= 0.25 && percent <= 0.50){
		if(percent == 0.25) {
		  percentage = 0;
		}
		else{
		  percentage = (((percent - 0.25) * 1) / (0.50 - 0.25));
		}
        return mixColor("#75cce4", "#3c95d4", percentage);
	}
	else if(percent >= 0.50 && percent <= 0.75){
		if(percent == 0.50) {
			percentage = 0;
		}
		else{
			percentage = (((percent - 0.50) * 1) / (0.75 - 0.50));
		}
		return mixColor("#3c95d4", "#13559d", percentage);
	}
	else if(percent >= 0.75 && percent <= 1){
		if(percent == 0.75) {
		  percentage = 0;
		}
		else{
		  percentage = (((percent - 0.75) * 1) / (1 - 0.75));
		}
        return mixColor("#13559d", "#143463", percentage);
	}
}

// function switchColor(percent){
// 	return mixColor("#ffcccc","#ff0000",percent);
// }

// mix two colors
function mixColor(color1, color2, percentage) {

  color1 = color1.substring(1);
  color2 = color2.substring(1);

  // Convert to RBG
  color1 = [parseInt(color1[0] + color1[1], 16), parseInt(color1[2] + color1[3], 16), parseInt(color1[4] + color1[5], 16)];
  color2 = [parseInt(color2[0] + color2[1], 16), parseInt(color2[2] + color2[3], 16), parseInt(color2[4] + color2[5], 16)];

  // mix the colors
  var color3 = [
    (1 - percentage) * color1[0] + percentage * color2[0],
    (1 - percentage) * color1[1] + percentage * color2[1],
    (1 - percentage) * color1[2] + percentage * color2[2]
  ];

  // convert to Hexadecimal
  color3 = '#' + intHex(color3[0]) + intHex(color3[1]) + intHex(color3[2]);

  // return color in hexadecimal
  return color3;
}

// Convert to Hexadecimal
function intHex(num)
{
  var hex = Math.round(num).toString(16);
  if (hex.length == 1)
    hex = '0' + hex;
  return hex;
}

// Set limits of range / min and max valueSlider
function setLimitGradient (minVal, maxVal) {
  spanMinNumber.innerHTML = Number(minVal).toFixed(2);
  spanMaxNumber.innerHTML = Number(maxVal).toFixed(2);
  sliderGradient.setAttribute('min', minVal);
  if(maxVal == "Sem dados"){
	  sliderGradient.setAttribute('max', 1);
  }
  else {
	  sliderGradient.setAttribute('max', maxVal);
  }
}