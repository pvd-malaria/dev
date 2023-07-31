var largura = 600,
    altura = 500;

// Area for Visualization
var visualization = d3.select("#visualization")
    .append("svg")
    .attr("width", largura)
    .attr("height",altura)
    .append("g");

var codigoVisualizacao;

// Data with JSON // name - value
function loadData(id) {
    d3.selectAll("rect").remove();
    d3.selectAll("text").remove();

    d3.json("static/website/json/exemplo.json", function (data) {
        var count = -1,
            countYear = -1,
            i;

        for(i = 0;i < data.visualizacaoTreemap.length; i++){

            if(id == data.visualizacaoTreemap[i].codigo){
                count = i;
                break;
            }
        }

        if(count != -1) {

            codigoVisualizacao = data.visualizacaoTreemap[count].codigo;

            for(i = 0;i < data.visualizacaoTreemap[count].dados.length;i++){
                if(sliderYear.value == data.visualizacaoTreemap[count].dados[i].ano){
                    countYear = i;
                    break;
                }
            }
            if(countYear != -1) {
                // define data with size of area in the leaves
                var dataVisualization = d3.hierarchy(data.visualizacaoTreemap[count].dados[countYear]).sum(function (d) {
                    return d.value;
                });

                // d3.treemap create a treemap with data
                d3.treemap()
                    .size([largura, altura])
                    .padding(1)
                    (dataVisualization);

                // Create visualization of treemap and add text
                visualization.selectAll("rect")
                    .data(dataVisualization.leaves())
                    .enter()
                    .append("rect")
                    .attr('x', function (d) {
                        return d.x0;
                    })
                    .attr('y', function (d) {
                        return d.y0;
                    })
                    .attr('width', function (d) {
                        return d.x1 - d.x0;
                    })
                    .attr('height', function (d) {
                        return d.y1 - d.y0;
                    })
                    .style("stroke", "#ffffff")
                    .style("fill", "#87CEFA");

                visualization.selectAll("text")
                    .data(dataVisualization.leaves())
                    .enter()
                    .append("text")
                    .attr("x", function (d) {
                        return d.x0 + 5
                    })
                    .attr("y", function (d) {
                        return d.y0 + 20
                    })
                    .text(function (d) {
                        return d.data.name;
                    })
                    .attr("font-size", "15px")
                    .attr("fill", "#ffffff");
            }
        }
    });
}