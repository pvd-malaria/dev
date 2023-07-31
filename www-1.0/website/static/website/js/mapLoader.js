
// Define scale
var width = 800,
    height = 800;

// Set map in the center
var projection = d3.geoMercator()
    .scale(1000)
    .center([-55 , -15])
    .translate([width / 2, height / 2]);

var path = d3.geoPath()
    .projection(projection);

// zoom variable
var zoom = d3.zoom()
    .scaleExtent([1, 20])
    .on("zoom", zoomMap);

// set zoomable map
function zoomMap() {
    map.attr("transform", d3.event.transform);
}

// set the area of map
var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height)
    .call(zoom);

// map get states/county/microregion
var mapState = "static/website/json/brasilEstados.json";
var mapCounty = "static/website/json/brasilMunicipio.json";
var mapMicroregion = "static/website/json/brasilMicrorregiao.json";


/*
function ButtonsZoomMap() {
// Set Buttons zoom sacelBy(selection, k)
// k is scale

    d3.select("#buttonPlus").on("click", function () {
        zoom.scaleBy(svg.transition().duration(300), 1.3);
    });

    d3.select("#buttonSub").on("click", function () {
        zoom.scaleBy(svg.transition().duration(300), 1 / 1.3);
    });
}

function ButtonsMoveMap() {
// Set Buttons move translateBy(selection, x , y)
// x and y is coordinates

    d3.select("#buttonUp").on("click", function () {
        zoom.translateBy(svg.transition().duration(300), 0, 10);
    });

    d3.select("#buttonDown").on("click", function () {
        zoom.translateBy(svg.transition().duration(300), 0, -10);
    });

    d3.select("#buttonLeft").on("click", function () {
        zoom.translateBy(svg.transition().duration(300), 10, 0);
    });

    d3.select("#buttonRight").on("click", function () {
        zoom.translateBy(svg.transition().duration(300), -10, 0);
    });
}
*/

function setupTip() {
    // Show name state
    tipState = d3.tip()
        .attr("class", "tip")
        .offset([-8, 0])
        .html(function (d) {
            return "State: " + d.properties.nome + "<br>Taxa de Mortalidade: " + Number(getNumberForJSON(getNumberState(d.id))).toFixed(2)
        });

    // Show name county
    tipCounty = d3.tip()
        .attr("class", "tip")
        .offset([-8, 0])
        .html(function (d) {
            return "County: " + d.properties.NM_MUNICIP.toLowerCase() + "<br>Taxa de Mortalidade: " + Number(getNumberForJSON(formatCounty(d.properties.CD_GEOCODM))).toFixed(2)
        });

    // Show name microregion
    tipMicroregion = d3.tip()
        .attr("class", "tip")
        .offset([-8, 0])
        .html(function (d) {
            return "Microregion: " + d.properties.NM_MICRO.toLowerCase() + "<br>Taxa de Mortalidade: " + Number(getNumberForJSON(d.properties.NM_MICRO)).toFixed(2)
        });
}

function colorState() {
    svg.selectAll("path")
        .attr("d", path)
        .style("fill", function(d) {
            // get te color for the state
            return getColor(getNumberState(d.id));
        })
}

function colorCounty() {

    svg.selectAll("path")
        .attr("d", path)
        .style("fill", function(d) {
            // get te color for the state
            return getColor(formatCounty(d.properties.CD_GEOCODM));
        })
}

function colorMicrorregion() {

    svg.selectAll("path")
        .attr("d", path)
        .style("fill", function(d) {
            // get te color for the state
            return getColor(d.properties.NM_MICRO);
        })
}

// remove bug in zoom
var map = svg.append("g")
    .attr("width", width)
    .attr("height", height);

// function is create map of state
function showStateMap(){
    // open map
    d3.json(mapState, function(error, topology) {
        if (error) throw error;

        map.attr("class", "estados")
            .selectAll("path")
            .data(topojson.feature(topology, topology.objects.estados).features)
            .enter()
            .append("path")
            .attr("d", path)
            .on('mouseover', tipState.show)
            .on('mouseout', tipState.hide)
            .on('click', function(d){
                loadData(getNumberState(d.id));
            });
    });
}

// function is create map of county
function showCountyMap(){
    // open map
    d3.json(mapCounty, function(error, topology) {
        if (error) throw error;

        map.attr("class", "bra")
            .selectAll("path")
            .data(topojson.feature(topology, topology.objects.bra).features)
            .enter()
            .append("path")
            .attr("d", path)
            .on('mouseover', tipCounty.show)
            .on('mouseout', tipCounty.hide)
            .on('click', function(d){
                loadData(formatCounty(d.properties.CD_GEOCODM));
            });
    });
}

// function is create map of Microregion
function showMicroregionMap(){

    // open map
    d3.json(mapMicroregion, function(error, topology) {
        if (error) throw error;

        map.attr("class", "bra")
            .selectAll("path")
            .data(topojson.feature(topology, topology.objects.bra).features)
            .enter()
            .append("path")
            .attr("d", path)
            .on('mouseover', tipMicroregion.show)
            .on('mouseout', tipMicroregion.hide)
            .on('click', function(d){
                loadData(d.properties.NM_MICRO);
            });
    });
}

// Initialize Functions

// Initialize Tip
setupTip();

svg.call(tipState);
svg.call(tipCounty);
svg.call(tipMicroregion);

/*
ButtonsZoomMap();

ButtonsMoveMap();
*/

switchMap();